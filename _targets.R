if(!require(pacman)) install.packages("pacman")
pacman::p_load(targets, tarchetypes, purrr, qs)

tar_option_set(packages = c("tidyverse", "data.table", "R.utils"),
               garbage_collection = TRUE,
               memory = "transient",
               format = "qs")

# Source R files
r_files <- c(
  "R/data_handlers.R"
)
purrr::map(r_files, source)

######## List targets ##########################################################

data_targets <- tar_plan(

  iterations = c(0, 11),

  event_cols = c(
    person = "character",
    time = "integer",
    type = "character",
    actType = "character",
    tourPurpose = "character",
    arrivalTime = "integer",
    departureTime = "integer",
    legMode = "character",
    mode = "character",
    currentTourMode = "character",
    vehicleType = "character",
    vehicle = "character",
    numPassengers = "integer",
    startX = "numeric",
    startY = "numeric",
    location = "integer",
    links = "character",
    linkTravelTime = "character",
    length = "numeric",
    reason = "character"
  ),
  
  data_location = c(
    existing = ""
  ),
  
  existing_data = get_if_needed(data_location["existing"], "data/existing.gz"),
  existing_dir = "data/wfrc_20_pct__2022-08-05_17-29-27_zfx",
  existing = read_iteration_events(existing_dir, event_cols, iterations,
                                   existing_data),
  
  scenarios = list(
    existing
  )
)
