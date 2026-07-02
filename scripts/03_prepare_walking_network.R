source(here::here("scripts", "00_utils.R"))
ensure_directories()

# Builds a routable pedestrian network from a local OpenStreetMap extract,
# filtered to walkable road types and clipped to the Atlanta study area.

tracts_acs <- readRDS(here::here("data_processed", "tracts_acs.rds"))
tracts_ll <- tracts_acs %>% st_transform(4326)
osm_pbf <- list.files(dirs$raw_osm, pattern = "\\.osm\\.pbf$", full.names = TRUE)

if (!length(osm_pbf)) {
  stop("No Georgia or Atlanta .osm.pbf extract in data_raw/osm.")
}

study_area_ll <- tracts_ll %>%
  st_bbox() %>%
  st_as_sfc() %>%
  st_buffer(0.05)

read_osm_layer <- function(layer_name) {
  st_read(
    osm_pbf[[1]],
    layer = layer_name,
    wkt_filter = st_as_text(study_area_ll),
    quiet = TRUE,
    stringsAsFactors = FALSE
  )
}
message("Reading clipped OSM lines from local PBF...")
walk_lines <- read_osm_layer("lines") %>%
  # Retain only pedestrian-relevant road types, excluding highways and motorways.
  filter(highway %in% c(
    "footway", "path", "pedestrian", "living_street", "residential",
    "service", "unclassified", "tertiary", "secondary", "primary"
  )) %>%
  st_transform(study_crs) %>%
  st_intersection(tracts_acs %>% st_union() %>% st_buffer(3000)) %>%
  st_cast("LINESTRING", warn = FALSE) %>%
  distinct(osm_id, .keep_all = TRUE) %>%
  select(osm_id, name, highway, geometry)

message("Building sfnetwork...")
walk_net <- walk_lines %>%
  sfnetworks::as_sfnetwork(directed = FALSE) %>%
  activate(edges) %>%
  mutate(weight = as.numeric(st_length(geometry)))

write_gpkg(walk_lines, here::here("data_processed", "walk_osm.gpkg"), "walk_osm")
save_rds(walk_net, here::here("data_processed", "walk_net.rds"))
