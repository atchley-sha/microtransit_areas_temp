if(!require(pacman)) install.packages("pacman")
pacman::p_load(targets, tarchetypes, purrr, qs)

tar_option_set(packages = c("tidyverse", "data.table", "R.utils", "archive"),
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

  #BEAM iterations to read in for each scenario
  iterations = c(11),
  
  #Names and types of cols to keep for events files
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
  
  #Where to download the scenario data
  data_locations = c(
    existing = ""
  ),
  
  ############################################
  
  #Existing scenario
  existing_dir = "data/existing",
  existing_data = get_if_needed(data_locations["existing"],
                                paste0(existing_dir, ".tar")),
  existing = read_iteration_events(existing_dir, event_cols, iterations,
                                   existing_data),
  
  
  #Combine all scenarios
  scenarios = list(
    existing
  ),
  
  ############################################
  
  #Get UTA On Demand pilot program info
  UTAOD <- read_csv("data/UTAODpilotinfo.csv")
  
)



analysis_targets <- tar_plan(
  
  total_riders <- map(scenarios,
                      get_tot_rh_passengers,
                      veh_type = "micro")
  
)



viz_targets <- tar_plan(
  
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