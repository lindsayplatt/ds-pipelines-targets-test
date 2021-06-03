
library(targets)
library(tarchetypes)
library(tidyverse)
library(retry)

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse", "dataRetrieval", "urbnmapr", "rnaturalearth", "cowplot", "lubridate",
                            "leaflet", "leafpop", "htmlwidgets"), 
               error = "continue")

# Load functions needed by targets below
source("1_fetch/src/find_oldest_sites.R")
source("1_fetch/src/get_site_data.R")
source("2_process/src/tally_site_obs.R")
source("2_process/src/summarize_targets.R")
source("3_visualize/src/plot_site_data.R")
source("3_visualize/src/plot_data_coverage.R")
source("3_visualize/src/map_sites.R")

# Configuration
states <- c('WI', 'MN', 'MI', 'IL')
parameter <- c('00060')

# Targets

  # Identify oldest sites
p1_targets <- list(
  tar_target(oldest_active_sites, find_oldest_sites(states, parameter))
)

# Do you split before `tar_map()` or within `tar_map()`?
# Thought I could do this without needing to write files out.

# state_splits <- tar_map(
#   values = tibble(state_abb = states),
#   tar_target(inventory_data, split_inventory(state_abb, oldest_active_sites))
# )

# BRANCHING!
state_branches <- tar_map(
  values = tibble(state_abb = states) %>%
    mutate(state_plot_files = sprintf("3_visualize/out/timeseries_%s.png", state_abb)),
  # Splitter:
  tar_target(inventory_data, split_inventory(state_abb, oldest_active_sites)),
  # Appliers
  tar_target(nwis_data, 
             retry(get_site_data(inventory_data, state_abb, parameter),
                   when = "Ugh, the internet data transfer failed!",
                   max_tries = 10)),
  tar_target(tally, tally_site_obs(nwis_data)),
  tar_target(timeseries_png, plot_site_data(state_plot_files, nwis_data, parameter), format="file"),
  names = state_abb,
  unlist = FALSE
)

p2_targets <- list(
  tar_combine(obs_tallies, state_branches[[3]], command = combine_obs_tallies(!!!.x))
)

p3_targets <- list(
  
  tar_target(data_coverage_png, plot_data_coverage(obs_tallies, "3_visualize/out/data_coverage.png", parameter), format = "file"),
  
  tar_combine(summary_state_timeseries_csv, state_branches[[4]], command = summarize_targets('3_visualize/out/summary_state_timeseries.csv', !!!.x), format="file"),
  
  # Add a leaflet map:
  tar_target(timeseries_map_html, map_timeseries(oldest_active_sites, summary_state_timeseries_csv, "3_visualize/out/timeseries_map.html"), format="file"),
  
  # Map oldest sites
  tar_target(
    site_map_png,
    map_sites("3_visualize/out/site_map.png", oldest_active_sites),
    format = "file"
  )
)
  

c(p1_targets,
  state_branches,
  p2_targets,
  p3_targets)
