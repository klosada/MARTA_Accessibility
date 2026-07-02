source(here::here("scripts", "00_utils.R"))
ensure_directories()

# NSA (Neighborhood Statistical Area) boundary used to clip census tracts to the Atlanta study area.
nsa_path <- list.files(dirs$raw_boundaries, pattern = "\\.(gpkg|geojson|shp)$", full.names = TRUE)
if (!length(nsa_path)) {
  stop("Atlanta / NSA boundary file not found.")
}

nsa_union <- st_read(nsa_path[[1]], quiet = TRUE) %>%
  st_transform(study_crs) %>%
  st_union()

# Pulls ACS tract boundaries and equity variables for the three study counties.
tracts_acs <- tidycensus::get_acs(
  geography = "tract",
  variables = acs_vars,
  state = state_fips,
  county = study_counties,
  year = acs_year,
  survey = "acs5",
  geometry = TRUE,
  output = "wide"
) %>%
  st_transform(study_crs) %>%
  transmute(
    GEOID,
    NAME,
    hhinc = hhincE,
    pct_minority = 100 * (1 - (white_nonhispE / total_popE)),
    pct_zero_vehicle = 100 * (zero_vehicle_hhE / total_hhE),
    total_pop = total_popE,
    total_hh = total_hhE,
    geometry
  ) %>%
  # st_point_on_surface ensures the origin point falls inside the polygon,
  # unlike st_centroid which can fall outside irregular tract boundaries.
  mutate(origin_geom = st_point_on_surface(geometry)) %>%
  filter(lengths(st_intersects(origin_geom, nsa_union)) > 0) %>%
  select(-origin_geom)

# Creates origin points from tract centroids for routing.
origins <- tracts_acs %>%
  mutate(origin_geom = st_point_on_surface(geometry)) %>%
  st_set_geometry("origin_geom") %>%
  select(GEOID, NAME, hhinc, pct_minority, pct_zero_vehicle)

write_gpkg(tracts_acs, here::here("data_processed", "tracts_acs.gpkg"), "tracts_acs")
write_gpkg(origins, here::here("data_processed", "origins.gpkg"), "origins")
save_rds(tracts_acs, here::here("data_processed", "tracts_acs.rds"))
save_rds(origins, here::here("data_processed", "origins.rds"))
