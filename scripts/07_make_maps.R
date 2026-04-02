source(here::here("scripts", "00_utils.R"))
ensure_directories()

tmap_mode("plot")

tracts_final <- readRDS(here::here("data_processed", "tracts_final.rds"))
destinations <- readRDS(here::here("data_processed", "destinations.rds"))
all_stops <- readRDS(here::here("data_processed", "all_stops.rds"))
rail_stops <- readRDS(here::here("data_processed", "rail_stops.rds"))

nsa_path <- list.files(dirs$raw_boundaries, pattern = "\\.(gpkg|geojson|shp)$", full.names = TRUE)
nsa_layer <- if (length(nsa_path)) st_read(nsa_path[[1]], quiet = TRUE) %>% st_transform(study_crs) else NULL

reference_map <- tm_shape(tracts_final) +
  tm_borders(col = "grey80", lwd = 0.4) +
  {if (!is.null(nsa_layer)) tm_shape(nsa_layer) + tm_borders(col = "black", lwd = 1) else NULL} +
  tm_shape(all_stops) + tm_dots(col = "grey60", size = 0.01, alpha = 0.5) +
  tm_shape(rail_stops) + tm_dots(col = "#0a4f6d", size = 0.03, alpha = 0.8) +
  tm_shape(destinations) + tm_symbols(col = "#d1495b", size = 0.12) +
  tm_text("dest_name", size = 0.55, ymod = 0.01) +
  tm_layout(title = "MARTA Accessibility Study Area", frame = FALSE)

rail_map <- tm_shape(tracts_final) +
  tm_polygons("rail_only_n_45", palette = "Blues", title = "Rail-only destinations <= 45 min") +
  tm_shape(destinations) + tm_symbols(col = "#111111", size = 0.08) +
  tm_layout(frame = FALSE)

bus_rail_map <- tm_shape(tracts_final) +
  tm_polygons("bus_rail_n_45", palette = "Greens", title = "Bus + rail destinations <= 45 min") +
  tm_shape(destinations) + tm_symbols(col = "#111111", size = 0.08) +
  tm_layout(frame = FALSE)

difference_map <- tm_shape(tracts_final) +
  tm_polygons("diff_n_45", palette = "-RdBu", midpoint = 0, title = "Difference in destinations <= 45 min") +
  tm_layout(frame = FALSE)

midtown_map <- tm_shape(tracts_final) +
  tm_polygons("bus_rail_midtown_tt", palette = "magma", title = "Midtown travel time (min)") +
  tm_shape(destinations %>% filter(dest_id == "midtown")) +
  tm_symbols(col = "#d1495b", size = 0.15) +
  tm_layout(frame = FALSE)

downtown_map <- tm_shape(tracts_final) +
  tm_polygons("bus_rail_downtown_tt", palette = "plasma", title = "Downtown travel time (min)") +
  tm_shape(destinations %>% filter(dest_id == "downtown")) +
  tm_symbols(col = "#d1495b", size = 0.15) +
  tm_layout(frame = FALSE)

tmap_save(reference_map, here::here("outputs", "maps", "map_01_reference.png"), width = 9, height = 7, dpi = 300)
tmap_save(rail_map, here::here("outputs", "maps", "map_02_rail_only.png"), width = 9, height = 7, dpi = 300)
tmap_save(bus_rail_map, here::here("outputs", "maps", "map_03_bus_rail.png"), width = 9, height = 7, dpi = 300)
tmap_save(difference_map, here::here("outputs", "maps", "map_04_difference.png"), width = 9, height = 7, dpi = 300)
tmap_save(midtown_map, here::here("outputs", "maps", "map_05_midtown.png"), width = 9, height = 7, dpi = 300)
tmap_save(downtown_map, here::here("outputs", "maps", "map_06_downtown.png"), width = 9, height = 7, dpi = 300)
