library(targets)
source("1_fetch/src/get_nwis_data.R")
source("2_process/src/process_and_style.R")
source("3_visualize/src/plot_timeseries.R")

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse", "dataRetrieval")) # Loading tidyverse because we need dplyr, ggplot2, readr, stringr, and purrr

# source("_targets_notasktable.R") # Build with no task table, as it was done in ds-pipelines-2
source("_targets_tasktable.R") # Build with task table method

target_list
