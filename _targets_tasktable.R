
library(tarchetypes)
library(tibble) # For some reason adding in `_targets.R` wasn't making a difference nor is the fact that it is included in tidyverse

sites_to_use <- c("01427207", "01432160", "01435000", "01436690", "01466500")

# A task-tablified version of the original ds-pipelines-2

# Similar to task tables, use tar_map to do the same thing across multiple sites
mapped_targets <- tar_map(
  values = tibble(site_no = sites_to_use, 
                  dl_site_file = sprintf("1_fetch/out/site_data_%s.csv", site_no)),
  names = "site_no",
  tar_target(
    dl_site,
    download_nwis_site_data(dl_site_file),
    format = "file"
  )
)

target_list <- list(
  mapped_targets,
  # Now combine and process
  tar_combine(
    combine_site_data,
    mapped_targets$dl_site, # This grabs all of the filenames that come out of the dl_site target in the mapped version
    command = combine_and_process_data("2_process/out/site_data.rds", !!!.x),
    format = "file"
  ),
  tar_target(site_info, nwis_site_info(combine_site_data)),
  tar_target(
    site_plot_data, 
    prepare_data_for_plot("2_process/out/site_data_plot.rds", combine_site_data, site_info),
    format = "file"
  ),
  # Now plot
  tar_target(
    figure_1, 
    plot_nwis_timeseries("3_visualize/out/figure_1.png", site_plot_data), 
    format = "file")
)

# Equivalent remake file for scipiper pipeline (except where the
# `do_site_tasks` function exists as an R script sources in remake.yml)

# targets:
#   all:
#   depends: 3_visualize/out/figure_1.png
# 
# sites:
#   command: c(
#     I("01427207"), 
#     I("01432160"), 
#     I("01435000"), 
#     I("01436690"), 
#     I("01466500"))
# 
# 2_process/out/site_data.rds:
#   command: do_site_tasks(
#     target_name, 
#     sites, 
#     '1_fetch/src/get_nwis_data.R', 
#     '2_process/src/process_and_style.R')
# 
# site_info:
#   command: nwis_site_info(
#     site_data_file = '2_process/out/site_data.rds')
# 
# 2_process/out/site_data_plot.rds:
#   command: prepare_data_for_plot(
#     target_name, 
#     site_data_file = '2_process/out/site_data.rds', 
#     site_info = site_info)
# 
# 3_visualize/out/figure_1.png:
#   command: plot_nwis_timeseries(fileout = '3_visualize/out/figure_1.png', 
#                                 '2_process/out/site_data_plot.rds')  

# do_site_tasks <- function(final_target, sites, ...) {
#   
#   dl_site_step <- create_task_step(
#     step_name = 'dl_site',
#     target_name = function(task_name, ...) {
#       sprintf("1_fetch/tmp/site_data_%s.csv", task_name)
#     },
#     command = function(...) {
#       "download_nwis_site_data(target_name)"
#     }
#   )
#   
#   # Create the task plan
#   task_plan <- create_task_plan(
#     task_names = sites,
#     task_steps = list(dl_site_step),
#     final_steps = c('dl_site'),
#     add_complete = FALSE)
#   
#   # Create the task remakefile
#   task_makefile <- 'site_tasks.yml'
#   create_task_makefile(
#     task_plan = task_plan,
#     makefile = task_makefile,
#     include = 'remake.yml',
#     sources = c(...),
#     packages = c('tidyverse', 'dataRetrieval', 'stringr', 'readr'),
#     final_targets = final_target,
#     finalize_funs = c('combine_and_process_data'),
#     as_promises = TRUE,
#     tickquote_combinee_objects = TRUE)
#   
#   loop_tasks(task_plan = task_plan,
#              task_makefile = task_makefile,
#              num_tries = 1)
#   
#   scdel(sprintf("%s_promise", basename(final_target)), remake_file=task_makefile)
#   file.remove(task_makefile)
#   
# }
