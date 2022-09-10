if(!require(pacman)) install.packages("pacman")
pacman::p_load(targets, tarchetypes, tidyverse, qs)

tar_option_set(
  packages = c(
    "tidyverse", "data.table", "R.utils", "archive", "magrittr"),
  garbage_collection = TRUE,
  format = "qs")

# Source R files
r_files <- c(
  "R/data_handlers.R",
  "R/summarize_events.R",
  "R/UTAOD_comparison.R"
)
purrr::map(r_files, source)

######## List targets ##########################################################

data_targets <- tar_plan(
  
  tar_target(EX, "data/wfrc_existing_events.csv.gz", format = "file"),
  tar_target(A, "data/wfrc_A_events.csv.gz", format = "file"),
  tar_target(B, "data/wfrc_B_events.csv.gz", format = "file"),
  tar_target(C, "data/wfrc_C_events.csv.gz", format = "file"),
  tar_target(D, "data/wfrc_D_events.csv.gz", format = "file"),
  
  # tar_target(EX_fleet, "data/wfrc_existing_fleet.csv", format = "file"),
  # tar_target(A_fleet, "data/wfrc_A_fleet.csv", format = "file"),
  # tar_target(B_fleet, "data/wfrc_B_fleet.csv", format = "file"),
  # tar_target(C_fleet, "data/wfrc_C_fleet.csv", format = "file"),
  # tar_target(D_fleet, "data/wfrc_D_fleet.csv", format = "file"),
  
  
  scenarios = list(
    existing = data.table::fread(file = EX, select = event_cols),
    A = data.table::fread(file = A, select = event_cols),
    B = data.table::fread(file = B, select = event_cols),
    C = data.table::fread(file = C, select = event_cols),
    D = data.table::fread(file = D, select = event_cols),
  ),
  # fleets = list(
  #   existing = read_csv(EX_fleet),
  #   A = read_csv(A_fleet),
  #   B = read_csv(B_fleet),
  #   C = read_csv(C_fleet),
  #   D = read_csv(D_fleet)
  # ),

  #Names and types of cols to keep for events files
  event_cols = c(
    person = "character",
    time = "numeric",
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
  
  #### UTA On Demand ##########################
  
  #Get UTA On Demand pilot program info
  tar_target(UTAOD, "data/UTAODpilotinfo.csv", format = "file"),
  
  #months for which the observed data is good
  good_months = c("JAN", "FEB", "MAR")
  
)



analysis_targets <- tar_plan(
  
  #### Ridehail events #######################
  
  ridehail_modes = c("ride_hail", "ride_hail_pooled", "ride_hail_transit"),
  # ridehail_path_traversal = purrr::map(
  #   scenarios,
  #   filter_to_ridehail_pt,
  #   veh_type = "micro",
  #   iters = iterations),
  total_riders = purrr::map(
    scenarios,
    get_tot_rh_passengers,
    iters = iterations),
  rh_trips = purrr::map(
    scenarios,
    get_ridehail_trips,
    ridehail_modes,
    iters = iterations),
  utilization = purrr::map2(
    total_riders, rh_fleets,
    get_rh_utilization,
    iters = iterations),
  average_wait_times = purrr::map(
    rh_wait_time_events_arranged,
    get_avg_rh_wait_time,
    iters = iterations),
  # ridehail_to_transit = c(number, percent, am, pm)
  
  rh_wait_time_events_arranged = purrr::map(
    scenarios,
    get_arranged_rh_wait_time_events,
    iterations)
  
)



viz_targets <- tar_plan(
  
  UTA = readr::read_csv(UTAOD) %>% 
    filter(Month %in% good_months) %>% 
    pivot_uta(),
  
  existing_comparison = compare_existing(
    UTA, iterations, total_riders$existing,
    utilization$existing,
    average_wait_times$existing)
)



render_targets <- tar_plan(
  
)


########### Run all targets ####################################################

tar_plan(
  data_targets,
  analysis_targets,
  viz_targets,
  render_targets
)