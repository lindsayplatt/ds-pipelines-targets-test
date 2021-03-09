# Initial ds-pipelines-2 state, where nothing is task tablified
target_list <- list(
  # Not doing task-table style since that isn't what ds-pipelines-2 uses
  # Instead, keeping the fetch steps as separate targets for each site
  tar_target(
    dl_site_01427207_data,
    download_nwis_site_data("1_fetch/out/site_data_01427207.csv"),
    format = "file"
  ),
  tar_target(
    dl_site_01432160_data,
    download_nwis_site_data("1_fetch/out/site_data_01432160.csv"),
    format = "file"
  ),
  tar_target(
    dl_site_01435000_data,
    download_nwis_site_data("1_fetch/out/site_data_01435000.csv"),
    format = "file"
  ),
  tar_target(
    dl_site_01436690_data,
    download_nwis_site_data("1_fetch/out/site_data_01436690.csv"),
    format = "file"
  ),
  tar_target(
    dl_site_01466500_data,
    download_nwis_site_data("1_fetch/out/site_data_01466500.csv"),
    format = "file"
  ),
  # Now combine and process
  tar_target(
    combine_site_data,
    combine_and_process_data(
      "2_process/out/site_data.rds",
      dl_site_01427207_data,
      dl_site_01432160_data,
      dl_site_01435000_data,
      dl_site_01436690_data,
      dl_site_01466500_data
    ),
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

# Equivalent remake file for scipiper pipeline:
# targets:
#   all:
#   depends: 3_visualize/out/figure_1.png
# 
# 1_fetch/out/site_data_01427207.csv:
#   command: download_nwis_site_data(target_name)
# 
# 1_fetch/out/site_data_01432160.csv:
#   command: download_nwis_site_data(target_name)
# 
# 1_fetch/out/site_data_01435000.csv:
#   command: download_nwis_site_data(target_name)
# 
# 1_fetch/out/site_data_01436690.csv:
#   command: download_nwis_site_data(target_name)
# 
# 1_fetch/out/site_data_01466500.csv:
#   command: download_nwis_site_data(target_name)
# 
# 2_process/out/site_data.rds:
#   command: combine_and_process_data(
#     target_name,
#     '1_fetch/out/site_data_01427207.csv',
#     '1_fetch/out/site_data_01432160.csv',
#     '1_fetch/out/site_data_01435000.csv',
#     '1_fetch/out/site_data_01436690.csv',
#     '1_fetch/out/site_data_01466500.csv')
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
