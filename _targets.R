library(targets)
library(tarchetypes)
library(tibble) # When used in `tar_map`, this seems to need to be loaded explicitly

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse", "dataRetrieval", "urbnmapr", "rnaturalearth", 
                            "cowplot", "leaflet", "leafpop", "htmlwidgets", "lubridate"))

# Load functions needed at top level of pipeline
source("1_fetch/src/find_oldest_sites.R")
source("1_fetch/src/get_site_data.R")
source("2_process/src/tally_site_obs.R")
source("3_visualize/src/plot_site_data.R")
source("3_visualize/src/plot_data_coverage.R")
source("3_visualize/src/map_sites.R")
source("3_visualize/src/map_timeseries.R")

# Some basic config:
states <- c("WI", "VA", "NY")
# states <- c('AL','AZ','AR','CA','CO','CT','DE','DC','FL','GA','ID','IL','IN','IA',
#             'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH',
#             'NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX',
#             'UT','VT','VA','WA','WV','WI','WY','AK','HI','GU','PR')

parameter <- '00060'

# Then do tasks by state
targets_by_state <- tar_map(
  values = tibble(state_abbr = states, 
                  state_info_file = sprintf("1_fetch/tmp/inventory_%s.tsv", state_abbr),
                  plot_file = sprintf("3_visualize/tmp/timeseries_%s.png", state_abbr)),
  names = state_abbr,
  tar_target(state_oldest_state, find_oldest_site(state_abbr, parameter)),
  tar_target(state_data, get_site_data(state_oldest_state, parameter)),
  tar_target(state_timeseries_plot, plot_site_data(plot_file, state_data, parameter), format = "file"),
  tar_target(state_tally, tally_site_obs(state_data))
)

# Now that mapping is complete, put all remaining targets into single list
# which is a `targets` requirement
list(
  targets_by_state,
  
  # Combine state oldest infos
  tar_combine(
    oldest_active_sites,
    targets_by_state$state_oldest_state,
    command = dplyr::bind_rows(!!!.x)
  ),
  
  # Combine obs into one obs tibble
  tar_combine(
    combine_obs_tallies,
    targets_by_state$state_tally,
    command = dplyr::bind_rows(!!!.x, .id = "state_cd")
  ),
  
  # Combine state plots into single vector of filepaths (default of tar_combine creates a vector)
  tar_combine(state_timeseries_files, targets_by_state$state_timeseries_plot),
  
  # Using all state data make a plot of data coverage, a map of all sites, and an interactive HTML
  # to explore data by state
  tar_target(
    plot_all_data,
    plot_data_coverage(combine_obs_tallies, "3_visualize/out/data_coverage.png", parameter),
    format = "file"
  ),
  tar_target(
    map_all_data,
    map_sites(oldest_active_sites, "3_visualize/out/site_map.png"),
    format = "file"
  ),
  tar_target(
    map_timeseries_interactive,
    map_timeseries(oldest_active_sites, state_timeseries_files, "3_visualize/out/timeseries_map.html"),
    format = "file"
  )
)
