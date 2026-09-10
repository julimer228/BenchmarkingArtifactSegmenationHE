library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(effectsize)
library(openxlsx)

df_all <- read.csv("C:/Repos/HistoKit/Statistical Analysis/Final/data/multiclass_results.csv")

df_long <- df_all %>%
  rename_with(
    ~ sub("\\.Present$", "_Present", .x),
    ends_with(".Present")
  ) %>%
  pivot_longer(
    cols = matches("_(DICE|Present)$"),
    names_to = c("Class", ".value"),
    names_pattern = "^(.*)_(DICE|Present)$"
  ) %>%
  filter(Present == 1) %>%
  mutate(
    Class = gsub("\\.", " ", Class)
  )

method_colors <- c(
  "HistoKit"         = "#66CD00",
  "GrandQC"          = "#836FFF",
  "Schreiber et al." = "#FF83FA",
  "Patil et al."     = "#FFD700",
  "HistoQC"          = "#00BFFF",
  "HistoROI"         = "#FF4500"
)

## Violin plots with DICE for each artifact class

ggplot(df_long, aes(x = Mode, y = DICE, fill = Mode)) +
  geom_violin(trim = TRUE, alpha=0.7) +
  geom_boxplot(
    width = 0.12,
    outlier.shape = NA
  ) +
  facet_grid(
    Dataset ~ Class,
    scales = "free_x",
    space = "free_x"
  ) +
  scale_fill_manual(values = method_colors) +
  theme_bw(base_size = 16) +
  labs(
    x = NULL,
    y = "Dice Index",
    fill = "Method"
  ) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )


method_levels <- c(
  "GrandQC",
  "HistoKit",
  "Patil et al."
)


# Prepare data for statistical analysis

df_stats <- df_long %>%
  filter(
    Present == 1,
    !is.na(DICE)
  ) %>%
  mutate(
    Mode = as.character(Mode),
    Dataset = as.character(Dataset),
    Class = as.character(Class)
  ) %>%
  select(
    Image,
    Dataset,
    Class,
    Mode,
    DICE
  ) %>%
  distinct(
    Image,
    Dataset,
    Class,
    Mode,
    .keep_all = TRUE
  )


# For each class:

# 1. Friedman test (only if >= 3 methods are available)
# 2. Pairwise Wilcoxon signed-rank tests
# 3. Benjamini-Hochberg correction for multiple testing
# 4. Effect size matched-pairs rank-biserial correlation

calculate_inferential_tests <- function(
    data,
    dataset_name,
    class_name
) {
  

  
  dat <- data %>%
    filter(
      Dataset == dataset_name,
      Class == class_name
    ) %>%
    select(
      Image,
      Mode,
      DICE
    ) %>%
    distinct(
      Image,
      Mode,
      .keep_all = TRUE
    )
  
  
  methods_available <- dat %>%
    filter(
      !is.na(Mode),
      !is.na(DICE)
    ) %>%
    distinct(Mode) %>%
    pull(Mode)
  
  
  methods <- method_levels[
    method_levels %in% methods_available
  ]
  
  
  additional_methods <- setdiff(
    methods_available,
    method_levels
  )
  
  methods <- c(
    methods,
    additional_methods
  )
  
  
  # FRIEDMAN TEST
  
  # Default
  friedman_result <- tibble(
    Dataset = dataset_name,
    Class = class_name,
    N_methods = length(methods),
    N_complete = NA_integer_,
    Statistic = NA_real_,
    df = NA_real_,
    p_value = NA_real_,
    Test_performed = FALSE
  )
  
  
  if (length(methods) >= 3) {
    
    friedman_wide <- dat %>%
      filter(
        Mode %in% methods
      ) %>%
      pivot_wider(
        names_from = Mode,
        values_from = DICE
      )
    
    
    complete_wide <- friedman_wide %>%
      filter(
        if_all(
          all_of(methods),
          ~ !is.na(.x)
        )
      )
    
    
    n_complete <- nrow(
      complete_wide
    )
    
    
    friedman_result$N_complete <- n_complete
    
    if (n_complete >= 2) {
      
      friedman_long <- complete_wide %>%
        pivot_longer(
          cols = all_of(methods),
          names_to = "Mode",
          values_to = "DICE"
        )
      
      
      ft <- friedman.test(
        DICE ~ Mode | Image,
        data = friedman_long
      )
      
      
      friedman_result <- tibble(
        Dataset = dataset_name,
        Class = class_name,
        N_methods = length(methods),
        N_complete = n_complete,
        Statistic = unname(
          ft$statistic
        ),
        df = unname(
          ft$parameter
        ),
        p_value = ft$p.value,
        Test_performed = TRUE
      )
    }
  }
  
  
 
  
  if (length(methods) < 2) {
    
    pairwise_results <- tibble()
    
  } else {
    
    pairs <- combn(
      methods,
      2,
      simplify = FALSE
    )
    
    
    pairwise_results <- map_dfr(
      pairs,
      function(pair) {
        
        m1 <- pair[1]
        m2 <- pair[2]
        
        
        n_m1 <- dat %>%
          filter(
            Mode == m1,
            !is.na(DICE)
          ) %>%
          distinct(Image) %>%
          nrow()
        
        
        n_m2 <- dat %>%
          filter(
            Mode == m2,
            !is.na(DICE)
          ) %>%
          distinct(Image) %>%
          nrow()
        
        
        pair_dat <- dat %>%
          filter(
            Mode %in% c(
              m1,
              m2
            )
          ) %>%
          pivot_wider(
            names_from = Mode,
            values_from = DICE
          ) %>%
          drop_na(
            all_of(
              c(
                m1,
                m2
              )
            )
          )
        
        
        x <- pair_dat[[m1]]
        y <- pair_dat[[m2]]
        
        n_paired <- length(x)
        

        
        if (n_paired < 2) {
          
          return(
            tibble(
              Method1 = m1,
              Method2 = m2,
              N_method1_valid = n_m1,
              N_method2_valid = n_m2,
              N_paired = n_paired,
              Median_Method1 = ifelse(
                n_paired > 0,
                median(x),
                NA_real_
              ),
              Median_Method2 = ifelse(
                n_paired > 0,
                median(y),
                NA_real_
              ),
              Median_Difference = ifelse(
                n_paired > 0,
                median(x - y),
                NA_real_
              ),
              W = NA_real_,
              p_value = NA_real_,
              RBC = NA_real_,
              RBC_CI_Lower = NA_real_,
              RBC_CI_Upper = NA_real_
            )
          )
        }
        
        d <- x - y
        d_nonzero <- d[d != 0]
      
        # rank-biserial correlation
        # RBC > 0: Method 1 tends to have higher DICE
        # RBC < 0: Method 2 tends to have higher DICE
          
          rbc_result <- suppressWarnings(
            effectsize::rank_biserial(
              x,
              y,
              paired = TRUE,
              ci = 0.95
            )
          )
          
          
          rbc <- rbc_result$r_rank_biserial
          rbc_ci_lower <- rbc_result$CI_low
          rbc_ci_upper <- rbc_result$CI_high
          
          

          # Paired Wilcoxon signed-rank test
          
          wt <- suppressWarnings(
            wilcox.test(
              x,
              y,
              paired = TRUE,
              exact = FALSE
            )
          )
          
          
          W_value <- unname(
            wt$statistic
          )
          
          p_value <- wt$p.value
        
        
        
        tibble(
          Method1 = m1,
          Method2 = m2,
          N_method1_valid = n_m1,
          N_method2_valid = n_m2,
          N_paired = n_paired,
          
          Median_Method1 = median(
            x,
            na.rm = TRUE
          ),
          
          Median_Method2 = median(
            y,
            na.rm = TRUE
          ),
          
          Median_Difference = median(
            x - y,
            na.rm = TRUE
          ),
          
          W = W_value,
          p_value = p_value,
          
          RBC = rbc,
          RBC_CI_Lower = rbc_ci_lower,
          RBC_CI_Upper = rbc_ci_upper
        )
      }
    )
    
    
    # Benjamini-Hochberg correction
    
    pairwise_results <- pairwise_results %>%
      mutate(
        p_adj_BH = p.adjust(
          p_value,
          method = "BH"
        ),
        
        significance = case_when(
          is.na(p_adj_BH) ~ NA_character_,
          p_adj_BH < 0.0001 ~ "****",
          p_adj_BH < 0.001 ~ "***",
          p_adj_BH < 0.01 ~ "**",
          p_adj_BH < 0.05 ~ "*",
          p_adj_BH < 0.10 ~ ".",
          TRUE ~ "ns"
        ),
        
        Dataset = dataset_name,
        Class = class_name,
        .before = 1
      ) %>%
      select(
        Dataset,
        Class,
        Method1,
        Method2,
        
        N_method1_valid,
        N_method2_valid,
        N_paired,
        
        Median_Method1,
        Median_Method2,
        Median_Difference,
        
        W,
        p_value,
        p_adj_BH,
        significance,
        
        RBC,
        RBC_CI_Lower,
        RBC_CI_Upper
      )
  }
  
  
  list(
    friedman = friedman_result,
    pairwise = pairwise_results
  )
}


# Run tests for every Dataset x Class

datasets <- unique(
  df_stats$Dataset
)

all_friedman <- list()
all_pairwise <- list()


for (ds in datasets) {
  
  classes <- df_stats %>%
    filter(
      Dataset == ds
    ) %>%
    distinct(Class) %>%
    pull(Class)
  
  
  for (class_name in classes) {
    
    message(
      "Statistical analysis: ",
      ds,
      " — ",
      class_name
    )
    
    
    result <- calculate_inferential_tests(
      data = df_stats,
      dataset_name = ds,
      class_name = class_name
    )
    
    
    key <- paste(
      ds,
      class_name,
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

friedman_table <- friedman_table %>%
  mutate(
    significance = case_when(
      is.na(p_value) ~ NA_character_,
      p_value < 0.0001 ~ "****",
      p_value < 0.001 ~ "***",
      p_value < 0.01 ~ "**",
      p_value < 0.05 ~ "*",
      p_value < 0.10 ~ ".",
      TRUE ~ "ns"
    )
  )


two_method_comparisons <- friedman_table %>%
  filter(
    N_methods == 2
  ) %>%
  select(
    Dataset,
    Class,
    N_methods
  )


insufficient_groups <- friedman_table %>%
  filter(
    N_methods < 2
  ) %>%
  select(
    Dataset,
    Class,
    N_methods
  )


# Save results to Excel

output_dir <- paste0(
  "C:/Repos/HistoKit/Statistical Analysis/Final/statistical_tests_results/"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


excel_file <- file.path(
  output_dir,
  "multiclass_DICE_statistical_analysis.xlsx"
)


wb <- createWorkbook()



header_style <- createStyle(
  textDecoration = "bold",
  halign = "center",
  valign = "center",
  border = "Bottom"
)


number_style <- createStyle(numFmt = "0.000")
pvalue_style <- createStyle(numFmt = "0.000E+00")


# Sheet 1: Friedman
addWorksheet(wb, "Friedman")
writeData(wb, sheet = "Friedman", x = friedman_table, headerStyle = header_style)
freezePane(wb, "Friedman", firstRow = TRUE)
setColWidths(wb, "Friedman", cols = 1:ncol(friedman_table), widths = "auto")


if ("p_value" %in% names(friedman_table)) {
  
  p_col <- which(
    names(friedman_table) == "p_value"
  )
  
  addStyle(
    wb,
    "Friedman",
    style = pvalue_style,
    rows = 2:(nrow(friedman_table) + 1),
    cols = p_col,
    gridExpand = TRUE
  )
}


# Sheet 2: Pairwise Wilcoxon

addWorksheet(
  wb,
  "Wilcoxon Pairwise"
)

writeData(
  wb,
  sheet = "Wilcoxon Pairwise",
  x = pairwise_table,
  headerStyle = header_style
)

freezePane(
  wb,
  "Wilcoxon Pairwise",
  firstRow = TRUE
)

setColWidths(
  wb,
  "Wilcoxon Pairwise",
  cols = 1:ncol(pairwise_table),
  widths = "auto"
)


p_cols <- which(
  names(pairwise_table) %in% c(
    "p_value",
    "p_adj_BH"
  )
)

if (length(p_cols) > 0) {
  
  addStyle(
    wb,
    "Wilcoxon Pairwise",
    style = pvalue_style,
    rows = 2:(nrow(pairwise_table) + 1),
    cols = p_cols,
    gridExpand = TRUE
  )
}


# Numeric formatting for effect sizes / medians
number_cols <- which(
  names(pairwise_table) %in% c(
    "Median_Method1",
    "Median_Method2",
    "Median_Difference",
    "RBC",
    "RBC_CI_Lower",
    "RBC_CI_Upper"
  )
)

if (length(number_cols) > 0) {
  
  addStyle(
    wb,
    "Wilcoxon Pairwise",
    style = number_style,
    rows = 2:(nrow(pairwise_table) + 1),
    cols = number_cols,
    gridExpand = TRUE
  )
}


# Sheet 3: Two-method comparisons
addWorksheet(
  wb,
  "Two Methods"
)

writeData(
  wb,
  sheet = "Two Methods",
  x = two_method_comparisons,
  headerStyle = header_style
)

setColWidths(
  wb,
  "Two Methods",
  cols = 1:max(
    1,
    ncol(two_method_comparisons)
  ),
  widths = "auto"
)



# Sheet 4: Insufficient groups
addWorksheet(
  wb,
  "Insufficient Groups"
)

writeData(
  wb,
  sheet = "Insufficient Groups",
  x = insufficient_groups,
  headerStyle = header_style
)

setColWidths(
  wb,
  "Insufficient Groups",
  cols = 1:max(
    1,
    ncol(insufficient_groups)
  ),
  widths = "auto"
)




saveWorkbook(
  wb,
  excel_file,
  overwrite = TRUE
)


message(
  "Excel file saved: ",
  excel_file
)