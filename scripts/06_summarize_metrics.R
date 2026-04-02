source(here::here("scripts", "00_utils.R"))
ensure_directories()

tracts_acs <- readRDS(here::here("data_processed", "tracts_acs.rds"))
travel_times_long <- readRDS(here::here("data_processed", "travel_times_long.rds"))

accessibility_summary <- travel_times_long %>%
  group_by(GEOID, scenario) %>%
  summarise(
    mean_tt = mean(travel_time_min, na.rm = TRUE),
    min_tt = min(travel_time_min, na.rm = TRUE),
    max_tt = max(travel_time_min, na.rm = TRUE),
    n_30 = sum(travel_time_min <= 30, na.rm = TRUE),
    n_45 = sum(travel_time_min <= 45, na.rm = TRUE),
    n_60 = sum(travel_time_min <= 60, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(across(c(mean_tt, min_tt, max_tt), ~ if_else(is.infinite(.x), NA_real_, .x)))

travel_time_wide <- travel_times_long %>%
  select(GEOID, scenario, dest_name, travel_time_min) %>%
  mutate(dest_name = stringr::str_replace_all(tolower(dest_name), "[^a-z0-9]+", "_")) %>%
  tidyr::pivot_wider(
    names_from = c(scenario, dest_name),
    values_from = travel_time_min,
    names_glue = "{scenario}_{dest_name}_tt"
  )

summary_wide <- accessibility_summary %>%
  tidyr::pivot_wider(
    names_from = scenario,
    values_from = c(mean_tt, min_tt, max_tt, n_30, n_45, n_60),
    names_glue = "{scenario}_{.value}"
  ) %>%
  mutate(
    diff_n_45 = bus_rail_n_45 - rail_only_n_45,
    diff_mean_tt = rail_only_mean_tt - bus_rail_mean_tt
  )

tracts_final <- tracts_acs %>%
  left_join(summary_wide, by = "GEOID") %>%
  left_join(travel_time_wide, by = "GEOID")

save_rds(accessibility_summary, here::here("data_processed", "accessibility_summary.rds"))
save_rds(tracts_final, here::here("data_processed", "tracts_final.rds"))
write_gpkg(tracts_final, here::here("data_processed", "tracts_final.gpkg"), "tracts_final")
readr::write_csv(accessibility_summary, here::here("outputs", "tables", "accessibility_summary.csv"))
