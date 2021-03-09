combine_and_process_data <- function(out_file, ...){
  nwis_data <- purrr:::map(list(...), readr::read_csv) %>% purrr::reduce(bind_rows)
  
  nwis_data_clean <- rename(nwis_data, water_temperature = X_00010_00000) %>% 
    select(-agency_cd, -X_00010_00000_cd, tz_cd)
  
  saveRDS(nwis_data_clean, out_file)
  return(out_file)
}

prepare_data_for_plot <- function(out_file, site_data_file, site_info){
  annotated_data <- left_join(readRDS(site_data_file), site_info, by = "site_no") %>% 
    select(station_name = station_nm, site_no, dateTime, water_temperature, latitude = dec_lat_va, longitude = dec_long_va)
  styled_data <- annotated_data %>% 
    mutate(station_name = as.factor(station_name))
  
  saveRDS(styled_data, out_file)
  return(out_file)
}
