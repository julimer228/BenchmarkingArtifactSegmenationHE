library(dplyr)
library(openxlsx)
library(ggplot2)

df<-read.csv("C:/Repos/HistoKit/Statistical Analysis/Final/data/processing_time.csv")

summary_table <- df %>%
  group_by(method) %>%
  summarise(
    n = sum(!is.na(time)),
    mean = mean(time, na.rm = TRUE),
    sd = sd(time, na.rm = TRUE),
    se = sd / sqrt(n),
    CI_lower = mean - qt(0.975, df = n - 1) * se,
    CI_upper = mean + qt(0.975, df = n - 1) * se,
    .groups = "drop"
  )

summary_table

write.xlsx(
  summary_table,
  "C:/Repos/HistoKit/Statistical Analysis/Final/supplementary_materials/processing_time_mean_ci.xlsx",
  rowNames = FALSE
)
