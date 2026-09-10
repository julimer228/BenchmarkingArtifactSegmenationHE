library(ggplot2)
library(tidyverse)
library(boot)
library(openxlsx)
library(ggsignif)
library(effectsize)


df <- read.csv("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/data/all_algorithms.csv")
# Output
output_dir <- paste0("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/supplementary_materials/")
plot_output_dir <- paste0("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/plots/")


set.seed(1234)

method_colors <- c(
  "HistoKit"        = "#66CD00",
  "GrandQC"         = "#836FFF",
  "Schreiber et al." = "#FF83FA",
  "Patil et al."    = "#FFD700",
  "HistoQC"         = "#00BFFF",
  "HistoROI"        = "#FF4500"
)

method_levels <- c(
  "GrandQC",
  "HistoKit",
  "HistoQC",
  "HistoROI",
  "Patil et al.",
  "Schreiber et al."
)


datasets <- unique(df$Dataset)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(plot_output_dir, recursive = TRUE, showWarnings = FALSE)

metrics <- c("DICE", "RECALL", "FDR")


median_ci <- function(x, conf = 0.95, R = 2000) {
  
  x <- x[!is.na(x)]

  # bootstrap median
  boot_result <- boot(data = x, statistic = function(data, indices) {
      median(data[indices])
    },
    R = R
  )

  alpha <- 1 - conf

  quantile(
    boot_result$t,
    probs = c(
      alpha / 2,
      1 - alpha / 2
    ),
    na.rm = TRUE,
    names = FALSE
  )
}

calculate_statistics <- function(data, dataset_name) {
  data %>%
    filter(
      Dataset == dataset_name,
      !is.na(Value)
    ) %>%
    group_by(
      Metric,
      Method
    ) %>%
    group_modify(
      ~ {
        x <- .x$Value
        
        n <- length(x)
        
        # Mean
        mean_value <- mean(x)
        sd_value <- sd(x)
        se <- sd_value / sqrt(n)
        
        
        t_critical <- qt(0.975, df =n-1)
        
        mean_ci_lower <-mean_value-t_critical*se
        mean_ci_upper <-mean_value+t_critical*se
        
        # median
        median_value <- median(x)
        median_ci_values <- median_ci(x, conf = 0.95, R = 2000)
        
        tibble(
          N = n,
          Mean = mean_value,
          SD = sd_value,
          Mean_CI_Lower = mean_ci_lower,
          Mean_CI_Upper = mean_ci_upper,
          Median = median_value,
          Median_CI_Lower =
            median_ci_values[1],
          Median_CI_Upper =
            median_ci_values[2]
        )
      }
    ) %>%
    ungroup() %>%
    mutate(
      Dataset = dataset_name,
      .before = 1
    )
}


prepare_long_data <- function(data) {
  data %>%
    mutate(
      Method = case_when(
        Mode == "constant" ~ "HistoKit",
        TRUE ~ as.character(Mode)
      )
    ) %>%
    pivot_longer(
      cols = all_of(metrics),
      names_to = "Metric",
      values_to = "Value"
    ) %>%
    mutate(
      Metric = recode(
        Metric,
        DICE   = "Dice",
        RECALL = "Sensitivity"
      ),

      Method = factor(
        Method,
        levels = method_levels
      )
    )
}


df_long <- prepare_long_data(df)


# statistics for each dataset
all_statistics <- map(datasets, ~ calculate_statistics(data = df_long, dataset_name = .x))

names(all_statistics) <- datasets
stats_all <- bind_rows(all_statistics)


stats_presentation <- stats_all %>%
  mutate(
    `Mean (95% CI)` = sprintf(
      "%.3f (%.3f–%.3f)",
      Mean,
      Mean_CI_Lower,
      Mean_CI_Upper
    ),
    `Median (95% CI)` = sprintf(
      "%.3f (%.3f–%.3f)",
      Median,
      Median_CI_Lower,
      Median_CI_Upper
    )
  ) %>%
  select(
    Dataset,
    Metric,
    Method,
    N,
    Mean,
    SD,
    Mean_CI_Lower,
    Mean_CI_Upper,
    Median,
    Median_CI_Lower,
    Median_CI_Upper,
    `Mean (95% CI)`,
    `Median (95% CI)`
  )

# Data availability - identify unprocessed images

calculate_availability <- function(raw_data, long_data) {
  
  raw_methods <- raw_data %>%
    mutate(
      Method = case_when(
        Mode == "constant" ~ "HistoKit",
        TRUE ~ as.character(Mode)
      )
    )

  total_images <- raw_methods %>%
    distinct(
      Dataset,
      Image
    ) %>%
    count(
      Dataset,
      name = "N_total"
    )

  processed_images <- raw_methods %>%
    distinct(
      Dataset,
      Method,
      Image
    ) %>%
    count(
      Dataset,
      Method,
      name = "N_processed"
    )

  valid_metrics <- long_data %>%
    group_by(
      Dataset,
      Method,
      Metric
    ) %>%
    summarise(
      N_valid = sum(
        !is.na(Value)
      ),
      .groups = "drop"
    ) %>%
    mutate(
      Method = as.character(Method)
    )

  valid_metrics %>%
    left_join(
      processed_images,
      by = c(
        "Dataset",
        "Method"
      )
    ) %>%
    left_join(
      total_images,
      by = "Dataset"
    ) %>%
    mutate(
      N_not_processed =
        N_total -
          N_processed,
      N_metric_missing =
        N_processed -
          N_valid
    ) %>%
    select(
      Dataset,
      Method,
      Metric,
      N_total,
      N_processed,
      N_not_processed,
      N_valid,
      N_metric_missing
    ) %>%
    arrange(
      Dataset,
      Metric,
      Method
    )
}


availability_table <- calculate_availability(raw_data = df, long_data = df_long)


# Statistical analysis
# 1. Friedman test to check if there is the difference between methods
# 2. Matched pairs Wilcoxon signed-rank test for each pair of methods
# 3. Multiple comparisons: Benjamini Hochberg correction.
# 4. Effect size: matched pairs rank-biserial correlation (rc).

calculate_inferential_tests <- function(data, dataset_name, metric_name) {
  
  dat <- data %>%
    filter(
      Dataset == dataset_name,
      Metric == metric_name
    ) %>%
    mutate(
      Method = as.character(Method)
    ) %>%
    select(
      Image,
      Method,
      Value
    ) %>%
    distinct(
      Image,
      Method,
      .keep_all = TRUE
    )
  
  methods <- dat %>%
    filter(
      !is.na(Method)
    ) %>%
    distinct(Method) %>%
    pull(Method)
  
  methods <- method_levels[method_levels %in% methods]
  
  friedman_wide <- dat %>%
    filter(
      Method %in% methods
    ) %>%
    pivot_wider(
      names_from = Method,
      values_from = Value
    )
  
  complete_wide <- friedman_wide %>%
    filter(
      if_all(
        all_of(methods),
        ~ !is.na(.x)
      )
    )
  
  n_complete <- nrow(complete_wide)
  
  friedman_result <- tibble(
    Dataset = dataset_name,
    Metric = metric_name,
    N_methods = length(methods),
    N_complete = n_complete,
    Statistic = NA_real_,
    df = NA_real_,
    p_value = NA_real_
  )
  
  friedman_long <- complete_wide %>%
    pivot_longer(
      cols = all_of(methods),
      names_to = "Method",
      values_to = "Value"
    )
  
  ft <- friedman.test(Value ~ Method | Image, data = friedman_long)
  
  friedman_result <- tibble(
    Dataset = dataset_name,
    Metric = metric_name,
    N_methods = length(methods),
    N_complete = n_complete,
    Statistic = unname(
      ft$statistic
    ),
    df = unname(
      ft$parameter
    ),
    p_value = ft$p.value
  )
  
  pairs <- combn(methods, 2, simplify = FALSE)
  
  pairwise_results <- map_dfr(
    pairs,
    function(pair) {
      m1 <- pair[1]
      m2 <- pair[2]
      
      n_m1 <- dat %>%
        filter(
          Method == m1,
          !is.na(Value)
        ) %>%
        distinct(Image) %>%
        nrow()
      
      n_m2 <- dat %>%
        filter(
          Method == m2,
          !is.na(Value)
        ) %>%
        distinct(Image) %>%
        nrow()
      
      pair_dat <- dat %>%
        filter(
          Method %in% c(m1, m2)
        ) %>%
        pivot_wider(
          names_from = Method,
          values_from = Value
        ) %>%
        drop_na(all_of(c(m1, m2)))
      
      x <- pair_dat[[m1]]
      y <- pair_dat[[m2]]
      
      n_paired <- length(x)
      
      d <- x - y
      d_nonzero <- d[d != 0]
      
      # Rank-biserial correlation
      # rc > 0 - Method1 tends to have higher values.
      # rc < 0 - Method2 tends to have higher values.
      
      rbc_result <- effectsize::rank_biserial(
        x,
        y,
        paired = TRUE,
        ci = 0.95
      )
      
      rbc <- rbc_result$r_rank_biserial
      rbc_ci_lower <- rbc_result$CI_low
      rbc_ci_upper <- rbc_result$CI_high
      
      wt <- suppressWarnings(
        wilcox.test(
          x,
          y,
          paired = TRUE,
          exact = FALSE
        )
      )
      
      W_value <- unname(wt$statistic)
      p_value <- wt$p.value
      
      tibble(
        Method1 = m1,
        Method2 = m2,
        N_method1_valid = n_m1,
        N_method2_valid = n_m2,
        N_paired = n_paired,
        W = W_value,
        p_value = p_value,
        RBC = rbc
      )
    }
  ) %>%
    mutate(
      p_adj = p.adjust(
        p_value,
        method = "BH"
      ),
      significance = case_when(
        is.na(p_adj) ~ NA_character_,
        p_adj < 0.0001 ~ "****",
        p_adj < 0.001 ~ "***",
        p_adj < 0.01 ~ "**",
        p_adj < 0.05 ~ "*",
        TRUE ~ "ns"
      ),
      Dataset = dataset_name,
      Metric = metric_name,
      .before = 1
    ) %>%
    select(
      Dataset,
      Metric,
      Method1,
      Method2,
      N_method1_valid,
      N_method2_valid,
      N_paired,
      W,
      p_value,
      p_adj,
      significance,
      RBC
    )
  
  list(
    friedman = friedman_result,
    pairwise = pairwise_results
  )
}


all_friedman <- list()
all_pairwise <- list()

for (ds in datasets) {
  available_metrics <- df_long %>%
    filter(
      Dataset == ds
    ) %>%
    distinct(Metric) %>%
    pull(Metric)

  for (metric_name in available_metrics) {
    message(
      "Inferential statistics: ",
      ds,
      " — ",
      metric_name
    )

    result <- calculate_inferential_tests(
      data = df_long,
      dataset_name = ds,
      metric_name = metric_name
    )

    key <- paste(
      ds,
      metric_name,
      sep = "_"
    )

    all_friedman[[key]] <-
      result$friedman

    all_pairwise[[key]] <-
      result$pairwise
  }
}


friedman_table <- bind_rows(all_friedman)
pairwise_table <- bind_rows(all_pairwise)

# code p-value
friedman_table <- friedman_table %>%
  mutate(
    significance = case_when(
      is.na(p_value) ~ NA_character_,
      p_value < 0.0001 ~ "****",
      p_value < 0.001 ~ "***",
      p_value < 0.01 ~ "**",
      p_value < 0.05 ~ "*",
      p_value <0.1 ~".",
      TRUE ~ "ns"
    )
  )


# Excel workbook
excel_file <- file.path(output_dir, "binary_metrics_statistical_analysis.xlsx")
wb <- createWorkbook()

header_style <- createStyle(
  textDecoration = "bold",
  halign = "center",
  valign = "center",
  border = "Bottom"
)

number_style <- createStyle(numFmt = "0.000")
pvalue_style <- createStyle(numFmt = "0.000E+00")

addWorksheet(wb,"Descriptive Statistics")

writeData(wb, sheet = "Descriptive Statistics", x = stats_presentation, headerStyle = header_style)
freezePane(wb, "Descriptive Statistics", firstRow = TRUE)

setColWidths(
  wb,
  "Descriptive Statistics",
  cols = 1:ncol(stats_presentation),
  widths = "auto"
)


addWorksheet(wb, "Data Availability")

writeData(wb, sheet = "Data Availability", x = availability_table, headerStyle = header_style)

freezePane(
  wb,
  "Data Availability",
  firstRow = TRUE
)

setColWidths(
  wb,
  "Data Availability",
  cols = 1:ncol(availability_table),
  widths = "auto"
)

addWorksheet(wb, "Friedman")

writeData(wb, sheet = "Friedman", x = friedman_table, headerStyle = header_style)

freezePane(wb, "Friedman", firstRow = TRUE)

setColWidths(
  wb,
  "Friedman",
  cols = 1:ncol(friedman_table),
  widths = "auto"
)

addWorksheet(wb, "Wilcoxon Posthoc")

writeData(
  wb,
  sheet = "Wilcoxon Posthoc",
  x = pairwise_table,
  headerStyle = header_style
)

freezePane(
  wb,
  "Wilcoxon Posthoc",
  firstRow = TRUE
)

setColWidths(
  wb,
  "Wilcoxon Posthoc",
  cols = 1:ncol(pairwise_table),
  widths = "auto"
)


saveWorkbook(
  wb,
  excel_file,
  overwrite = TRUE
)



# Prepare data for plotting
plot_data_all <- df_long %>%
  filter(
    !is.na(Value)
  ) %>%
  mutate(
    Method = factor(
      Method,
      levels = method_levels
    )
  )


# Violin plots

plot_data_faceted <- plot_data_all %>%
  mutate(
    Dataset = factor(
      Dataset,
      levels = c("Dataset A", "Dataset B", "Dataset C")
    ),
    
    Metric = factor(
      Metric,
      levels = unique(Metric)
    )
  )

p_violin_faceted <- ggplot(
  plot_data_faceted,
  aes(
    x = Method,
    y = Value,
    fill = Method
  )
) +
  geom_violin(
    trim = TRUE,
    scale = "width",
    alpha = 0.7,
    linewidth = 0.4
  ) +
  geom_boxplot(
    outlier.shape = NA,
    width = 0.12,
    linewidth = 0.4
  ) +
  facet_grid(
    rows = vars(Dataset),
    cols = vars(Metric)
  ) +
  scale_fill_manual(
    values = method_colors,
    drop = FALSE
  ) +
  coord_cartesian(
    ylim = c(0, 1)
  ) +
  labs(
    x = NULL,
    y = NULL,
    fill = "Method"
  ) +
  theme_bw(
    base_size = 16
  ) +
  theme(
    
    legend.position = "bottom",

    strip.text = element_text(
      face = "bold",
      size = 13
    ),
    
    strip.background = element_rect(
      fill = "grey95",
      color = "black"
    ),
    
    
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.spacing = unit(
      0.8,
      "lines"
    ),
    
    legend.title = element_text(
      face = "bold"
    )
  )


p_violin_faceted

ggsave(
  filename = file.path(
    plot_output_dir,
    "Fig3_Violin_Binary.pdf"
  ),
  plot = p_violin_faceted,
  width = 14,
  height =8,
  bg = "white"
)