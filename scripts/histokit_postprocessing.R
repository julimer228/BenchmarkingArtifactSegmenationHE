library(ggplot2)
library(tidyverse)
library(patchwork)
library(cowplot)

# Load processed data
df_post_all <- read.csv("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/data/binary_histokit_postprocessed.csv")
df_no_all <- read.csv("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/data/binary_histokit_nopostprocessing.csv")

postprocessing <- c("postprocessed", "no postprocessing")
stats <- c("Median", "Mean")
datasets <- c("all", "Dataset A", "Dataset B", "Dataset C")
metrics <- c("DICE", "RECALL", "FDR")


for (stat in stats) {
  for (ds in datasets) {
    df_post <- df_post_all
    df_no <- df_no_all
    
    # dataset filtering
    if (ds != "all") {
      df_post <- df_post_all[df_post_all$Dataset == ds, ]
      df_no   <- df_no_all[df_no_all$Dataset == ds, ]}
    
    
    df_post_long <- df_post %>%
      pivot_longer(
        cols = all_of(metrics),
        names_to = "Metric",
        values_to = "Value"
      )
    
    df_no_long <- df_no %>%
      pivot_longer(
        cols = all_of(metrics),
        names_to = "Metric",
        values_to = "Value"
      )
    
    dfs <- list(
      post = df_post_long,
      no   = df_no_long
    )
    
    for (df_name in names(dfs)) {
      df_long <- dfs[[df_name]]
      
      ## Heatmaps for each df
      if (stat == "Median") {
        
        heatmap_data <- df_long %>%
          group_by(
            Overlap,
            Sigma,
            Mode,
            Metric
          ) %>%
          summarise(
            Value = median(
              Value,
              na.rm = TRUE
            ),
            .groups = "drop"
          )
        
      } else {
        
        heatmap_data <- df_long %>%
          group_by(
            Overlap,
            Sigma,
            Mode,
            Metric
          ) %>%
          summarise(
            Value = mean(
              Value,
              na.rm = TRUE
            ),
            .groups = "drop"
          )
      }
      
      heatmap_data <- heatmap_data %>%
        mutate(
          
          Sigma_label = case_when(
            Mode == "constant" ~ "",
            TRUE ~ as.character(Sigma)
          ),
          
          Metric = recode(
            Metric,
            RECALL = "Sensitivity",
            DICE = "Dice",
            FDR = "FDR"
          ),
          
          Metric = factor(
            Metric,
            levels = c(
              "Dice",
              "Sensitivity",
              "FDR"
            )
          ),
          
          Mode = recode(
            Mode,
            gaussian = "Gaussian",
            constant = "Constant"
          )
        )
      
      
      # min / max      
      heatmap_data <- heatmap_data %>%
        group_by(Metric) %>%
        mutate(
          is_max = Value == max(
            Value,
            na.rm = TRUE
          ),
          is_min = Value == min(
            Value,
            na.rm = TRUE
          )
        ) %>%
        ungroup()
      
      # plot heatmaps for each df
      plots <- heatmap_data %>%
        split(.$Metric) %>%
        map(
          ~ ggplot(
            .x,
            aes(
              x = factor(Overlap),
              y = factor(Sigma_label),
              fill = Value
            )
          ) +
            
            geom_tile(
              color = "white"
            ) +
            
            geom_text(
              aes(
                label = sprintf(
                  "%.4f",
                  Value
                ),
                color = Value >
                  (
                    min(Value, na.rm = TRUE) +
                      max(Value, na.rm = TRUE)
                  ) / 2
              ),
              size = 5,
              fontface = "bold"
            ) +
            
            scale_color_manual(
              values = c(
                "TRUE" = "black",
                "FALSE" = "white"
              ),
              guide = "none"
            ) +
            
            # MAX
            geom_tile(
              data = filter(.x, is_max),
              fill = NA,
              color = "red",
              linewidth = 1.5
            ) +
            
            # MIN
            geom_tile(
              data = filter(.x, is_min),
              fill = NA,
              color = "#149ed9",
              linewidth = 1.5
            ) +
            
            scale_fill_continuous(
              low = "#011403",
              high = "#0cfa24",
              labels = function(x) {
                sprintf("%.4f", x)
              },
              name = stat
            ) +
            
            facet_grid(
              cols = vars(Mode),
              scales = "free_x",
              space = "free_x"
            ) +
            
            theme_bw() +
            coord_flip() +
            
            labs(
              y = "                 Std",
              title = unique(.x$Metric),
              x = NULL
            ) +
            
            theme(
              axis.ticks = element_blank(),
              
              strip.background.x = element_rect(
                fill = "grey85",
                colour = "white",
                linewidth = 0.5
              ),
              
              strip.text.x = element_text(
                face = "bold",
                size = 16
              ),
              
              panel.border = element_blank()
            )
        )
      
      
      combined_plot <- wrap_plots(
        plots,
        ncol = 3
      ) +
        plot_annotation(
          theme = theme(
            plot.margin = margin(
              t = 5,
              r = 5,
              b = 20,
              l = 35
            )
          )
        )
      
      main_plot <- ggdraw(
        combined_plot
      ) +
        draw_label(
          "Mode",
          x = 0.5,
          y = 0.005,
          hjust = 0.5,
          vjust = 0,
          size = 15
        ) +
        draw_label(
          "Overlap",
          x = 0.02,
          y = 0.5,
          hjust = 0.5,
          vjust = 0,
          size = 15,
          angle = 90
        )
      
      
      legend_plot <- ggplot(
        data.frame(
          x = 1,
          y = 1,
          type = factor(
            c("MIN", "MAX"),
            levels = c("MIN", "MAX")
          )
        ),
        aes(
          x = x,
          y = y,
          color = type
        )
      ) +
        
        geom_tile(
          fill = NA,
          linewidth = 1.5
        ) +
        
        scale_color_manual(
          values = c(
            "MIN" = "#149ed9",
            "MAX" = "red"
          ),
          labels = c(
            "MIN" = "Min",
            "MAX" = "Max"
          ),
          name = NULL
        ) +
        
        guides(
          color = guide_legend(
            override.aes = list(
              fill = NA,
              linewidth = 1.5
            ),
            ncol = 1
          )
        ) +
        
        theme_void() +
        
        theme(
          legend.position = "right",
          legend.direction = "vertical",
          legend.text = element_text(
            size = 10
          ),
          legend.key.size = grid::unit(
            0.5,
            "cm"
          )
        )
      
      outline_legend <- cowplot::get_legend(legend_plot)
      
      final_plot <- cowplot::plot_grid(
        main_plot,
        outline_legend,
        ncol = 2,
        rel_widths = c(
          1,
          0.07
        ),
        align = "h"
      )
      
      
      ggsave(
        filename = paste0(
          "C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/plots/HistoKit (",
          df_name,
          ")_",
          stat,
          "_",
          ds,
          ".png"
        ),
        plot = final_plot,
        width = 20,
        height = 3.5,
        units = "in",
        dpi = 300
      )
      
    } 
    
    # Difference Heatmaps
    # Pair by image
    paired_data <- df_post_long %>%
      inner_join(
        df_no_long,
        by = c(
          "Image",
          "Dataset",
          "Overlap",
          "Sigma",
          "Mode",
          "Metric"
        ),
        suffix = c("_post", "_no")
      ) %>%
      mutate(
        Difference = Value_post - Value_no # calculate difference between scores
      )
    
    
    # aggregate differences
    if (stat == "Median") {
      
      heatmap_data <- paired_data %>%
        group_by(
          Overlap,
          Sigma,
          Mode,
          Metric
        ) %>%
        summarise(
          Difference = median(
            Difference,
            na.rm = TRUE
          ),
          .groups = "drop"
        )
      
    } else {
      
      heatmap_data <- paired_data %>%
        group_by(
          Overlap,
          Sigma,
          Mode,
          Metric
        ) %>%
        summarise(
          Difference = mean(
            Difference,
            na.rm = TRUE
          ),
          .groups = "drop"
        )
    }
    
    # formatting
    heatmap_data <- heatmap_data %>%
      mutate(
        Sigma_label = case_when(
          Mode == "constant" ~ "",
          TRUE ~ as.character(Sigma)
        ),
        
        Metric = recode(
          Metric,
          RECALL = "Sensitivity",
          DICE = "Dice",
          FDR = "FDR"
        ),
        
        Metric = factor(
          Metric,
          levels = c(
            "Dice",
            "Sensitivity",
            "FDR"
          )
        ),
        
        Mode = recode(
          Mode,
          gaussian = "Gaussian",
          constant = "Constant"
        )
      )
    
    
    # plot differences
    plots <- heatmap_data %>%
      split(.$Metric) %>%
      map(
        ~ ggplot(
          .x,
          aes(
            x = factor(Overlap),
            y = factor(Sigma_label),
            fill = Difference
          )
        ) +
          geom_tile(
            color = "white"
          ) +
          
          geom_text(
            aes(
              label = sprintf(
                "%+.2e",
                Difference
              )
            ),
            size = 4,
            fontface = "bold"
          ) +
          
          scale_fill_gradient2(
            low = "#149ed9",
            mid = "white",
            high = "red",
            midpoint = 0,
            labels = function(x) {
              sprintf("%+.2e", x)
            },
            name = paste0(
              stat,
              "\nDifference"
            )
          ) +
          
          facet_grid(
            cols = vars(Mode),
            scales = "free_x",
            space = "free_x"
          ) +
          
          theme_bw() +
          coord_flip() +
          
          labs(
            y = "                 Std",
            title = unique(.x$Metric),
            x = NULL
          ) +
          
          theme(
            axis.ticks = element_blank(),
            
            strip.background.x = element_rect(
              fill = "grey85",
              colour = "white",
              linewidth = 0.5
            ),
            
            strip.text.x = element_text(
              face = "bold",
              size = 14
            ),
            
            panel.border = element_blank()
          )
      )
    
    combined_plot <- wrap_plots(
      plots,
      ncol = 3
    ) +
      plot_annotation(
        theme = theme(
          plot.margin = margin(
            t = 5,
            r = 5,
            b = 20,
            l = 35
          )
        )
      )
    
    final_plot <- ggdraw(
      combined_plot
    ) +
      draw_label(
        "Mode",
        x = 0.5,
        y = 0.005,
        hjust = 0.5,
        vjust = 0,
        size = 15
      ) +
      draw_label(
        "Overlap",
        x = 0.02,
        y = 0.5,
        hjust = 0.5,
        vjust = 0,
        size = 15,
        angle = 90
      )
    ggsave(
      filename = paste0(
        "C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/plots/",
        stat,
        "_",
        ds,
        "_difference.png"
      ),
      plot = final_plot,
      width = 20,
      height = 3,
      units = "in",
      dpi = 300
    )
  }
}