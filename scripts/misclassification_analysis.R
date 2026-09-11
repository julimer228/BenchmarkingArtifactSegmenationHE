library(patchwork)
library(dplyr)
library(tidyr)
library(ggplot2)


cm_all <- read.csv("C:/Repos/Benchmarking-Artifact-Segmentation-Methods-in-H-E-Stained-Whole-Slide-Imaging/data/misclassification_analysis.csv")

# Dataset B

class_order_B <- c(
  "Tissue",
  "Fold",
  "Dark Spot",
  "Pen",
  "Edge",
  "Out of Focus"
)

cm_B <- cm_all %>%
  filter(
    Dataset == "Dataset B",
    GroundTruth != "Background",
    Prediction != "Background"
  ) %>%
  mutate(
    GroundTruth = factor(
      as.character(GroundTruth),
      levels = rev(class_order_B)
    ),
    Prediction = factor(
      as.character(Prediction),
      levels = class_order_B
    )
  ) %>%
  droplevels()

# Dataset C

class_order_C <- c(
  "Tissue",
  "Background",
  "Fold",
  "Dark Spot",
  "Pen",
  "Edge",
  "Out of Focus"
)

cm_C <- cm_all %>%
  filter(
    Dataset == "Dataset C"
  ) %>%
  mutate(
    GroundTruth = factor(
      as.character(GroundTruth),
      levels = rev(class_order_C)
    ),
    Prediction = factor(
      as.character(Prediction),
      levels = class_order_C
    )
  ) %>%
  droplevels()



p_B <- ggplot(
  cm_B,
  aes(
    x = Prediction,
    y = GroundTruth,
    fill = Percent
  )
) +
  
  geom_tile(
    color = "white",
    linewidth = 0.5
  ) +
  
  geom_text(
    aes(
      label = ifelse(
        is.na(Percent),
        "",
        sprintf("%.1f", Percent)
      )
    ),
    size = 3.5,
    fontface = "bold"
  ) +
  
  scale_fill_gradient(
    low = "white",
    high = "#1e9437",
    limits = c(0, 100),
    name = "%"
  ) +
  
  facet_grid(
    Dataset ~ Method
  ) +
  
  coord_fixed() +
  
  labs(
    x = NULL,
    y = "Ground truth",
    fill = "Pixel [%]"
  ) +
  
  theme_bw(base_size = 14) +
  
  theme(
    panel.grid = element_blank(),
    
    axis.title = element_text(
      face = "bold"
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    
    strip.text = element_text(
      face = "bold",
      size = 14
    ),
    
    legend.title = element_text(
      face = "bold"
    )
  )

p_C <- ggplot(
  cm_C,
  aes(
    x = Prediction,
    y = GroundTruth,
    fill = Percent
  )
) +
  
  geom_tile(
    color = "white",
    linewidth = 0.5
  ) +
  
  geom_text(
    aes(
      label = ifelse(
        is.na(Percent),
        "",
        sprintf("%.1f", Percent)
      )
    ),
    size = 3.5,
    fontface = "bold"
  ) +
  
  scale_fill_gradient(
    low = "white",
    high = "#1e9437",
    limits = c(0, 100),
    name = "%"
  ) +
  
  facet_grid(
    Dataset ~ Method
  ) +
  
  coord_fixed() +
  
  labs(
    x = "Predicted Class",
    y = "Ground Truth",
    fill = "Pixel [%]"
  ) +
  
  theme_bw(base_size = 14) +
  
  theme(
    panel.grid = element_blank(),
    
    axis.title = element_text(
      face = "bold"
    ),
    
    strip.text = element_text(
      face = "bold",
      size = 14
    ),
    
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    
    legend.title = element_text(
      face = "bold"
    )
  )

p_combined <- p_B / p_C +
  plot_layout(
    guides = "collect"
  ) &
  theme(
    legend.position = "right"
  )

print(p_combined)
