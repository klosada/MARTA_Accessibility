source(here::here("scripts", "00_utils.R"))
ensure_directories()

destinations <- destinations_tbl %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE) %>%
  st_transform(study_crs)

write_gpkg(destinations, here::here("data_processed", "destinations.gpkg"), "destinations")
save_rds(destinations, here::here("data_processed", "destinations.rds"))
