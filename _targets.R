library(targets)

source("code.R")
options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse", "stringr", "sbtools", "whisker"))

list(
  tar_target(
    sb_csv_downloaded,
    download_data("1_fetch/out/model_RMSEs.csv", "me_RMSE.csv"),
    format = "file"
  ), 
  tar_target(
    plot_data,
    process_data(sb_csv_downloaded),
  ),
  tar_target(
    generate_figure,
    make_plot("3_visualize/out/figure_1.png", plot_data), 
    format = "file"
  )
)

# The targets code above is equivalent to this in `scipiper`: 

# sources:
#   - code.R
# 
# targets:
#   all:
#     depends: figure_1.png
# 
# model_RMSEs.csv:
#   command: download_data(out_filepath = target_name)
# 
# plot_data:
#   command: process_data(in_filepath = "model_RMSEs.csv")
# 
# figure_1.png:
#   command: make_plot(out_filepath = target_names, data = plot_data)
