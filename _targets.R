if(!require(pacman)) install.packages("pacman")
pacman::p_load(targets, tarchetypes, tidyverse, qs)

tar_option_set(
  packages = c(
    "tidyverse", "data.table", "R.utils", "archive", "magrittr"),
  garbage_collection = TRUE,
  memory = "transient",
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
  
  #BEAM iterations to read in for each scenario
  iterations = c(1),
  
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
  
  #Where to download the scenario data
  data_locations = c(
    existing = ""
  ),
  
  #### Scenarios ##############################
  
  #Existing scenario
  existing_dir = "data/existing",
  existing_data = get_if_needed(
    data_locations["existing"],
    paste0(existing_dir, ".tar")),
  existing = read_iteration_events(
    existing_dir, event_cols, iterations,
    existing_data),
  existing_fleet = read_ridehail_fleet(paste0(existing_dir, "/rh_fleet.csv")),
  
  
  #Combine all scenarios
  scenarios = list(
    "existing" = existing
  ),
  rh_fleets = list(
    "existing" = existing_fleet
  ),
  
  #### UTA On Demand ##########################
  
  #Get UTA On Demand pilot program info
  UTAOD = readr::read_csv("data/UTAODpilotinfo.csv") %>% 
    filter(Month %in% good_months),
  
  #months for which the observed data is good
  good_months = c("JAN", "FEB", "MAR")
  
)



analysis_targets <- tar_plan(
  
  #### Ridehail events #######################
  
  ridehail_modes = c("ride_hail", "ride_hail_pooled", "ride_hail_transit"),
  ridehail_events = purrr::map(
    scenarios,
    filter_to_ridehail,
    veh_type = "micro",
    iters = iterations),
  total_riders = purrr::map(
    ridehail_events,
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
    function(x){
      x[type %in% c(
        "ReserveRideHail",
        "PersonEntersVehicle")
        ][order(person, time)]
    })
  
)



viz_targets <- tar_plan(
  
  UTA = pivot_uta(UTAOD),
  
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