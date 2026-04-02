options(tigris_use_cache = TRUE)
options(stringsAsFactors = FALSE)

suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(tidycensus)
  library(tigris)
  library(tidytransit)
  library(osmdata)
  library(sfnetworks)
  library(tidygraph)
  library(units)
  library(tmap)
  library(leaflet)
  library(here)
  library(glue)
  library(purrr)
})

study_crs <- 5070
acs_year <- 2023
state_fips <- "13"
study_counties <- c("063", "089", "121") # Clayton, DeKalb, Fulton
study_county_names <- c("Clayton", "DeKalb", "Fulton")

walk_speed_m_per_min <- 80
max_walk_minutes <- 10
max_walk_meters <- walk_speed_m_per_min * max_walk_minutes
dest_walk_meters <- 800

analysis_weekday <- "wednesday"
peak_start <- "07:00:00"
peak_end <- "10:00:00"
peak_time_range <- c(peak_start, peak_end)
max_transfers <- 3L

acs_vars <- c(
  hhinc = "B19013_001",
  total_pop = "B03002_001",
  white_nonhisp = "B03002_003",
  total_hh = "B08201_001",
  zero_vehicle_hh = "B08201_002"
)

destinations_tbl <- tibble::tribble(
  ~dest_id, ~dest_name, ~dest_type, ~lon, ~lat,
  "midtown", "Midtown", "job_center", -84.3863, 33.7812,
  "downtown", "Downtown", "job_center", -84.3915, 33.7537,
  "gatech", "Georgia Tech", "education", -84.3963, 33.7756,
  "emory", "Emory", "education", -84.3238, 33.7925,
  "grady", "Grady Memorial Hospital", "hospital", -84.3811, 33.7523,
  "piedmont", "Piedmont Atlanta Hospital", "hospital", -84.3942, 33.8070,
  "atl", "Hartsfield-Jackson Atlanta International Airport", "airport", -84.4277, 33.6407
)

dirs <- list(
  raw_gtfs = here::here("data_raw", "gtfs"),
  raw_boundaries = here::here("data_raw", "boundaries"),
  raw_osm = here::here("data_raw", "osm"),
  raw_destinations = here::here("data_raw", "destinations"),
  processed = here::here("data_processed"),
  tables = here::here("outputs", "tables"),
  figures = here::here("outputs", "figures"),
  maps = here::here("outputs", "maps")
)
