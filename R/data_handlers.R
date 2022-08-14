#### Functions for reading and handling data ###################################

#' Read in events.csv(.gz) files of specific iterations in a given scenario
#'
#' @param scenario_dir Directory of scenario outputs (parent directory of `ITERS`)
#' @param event_cols The names of columns to read in
#' @param iters Iteration numbers whose events to read (vector or single integer)
#' 
#' @return A list of events tibbles for the scenario
#' 
#' @export
#'
read_iteration_events <- function(scenario_dir, event_cols, iters, ...){
 
  scenario <- list()
  
  for (i in 1:length(iters)){
    iter <- iters[i]
    
    # csvgz_file <- paste0(
    #   scenario_dir, "/ITERS/it.", iter, "/", iter, ".events.csv.gz"
    # )
    # csv_file <- paste0(
    #   scenario_dir, "/ITERS/it.", iter, "/", iter, ".events.csv"
    # )
    # 
    # if (file.exists(csv_file)){
    #   events_file <- data.table::fread(file = csv_file, select = event_cols)
    # } else if (file.exists(csvgz_file)){
    #   events_file <- data.table::fread(file = csvgz_file, select = event_cols)
    # } else{
    #   events_file <- "No events.csv(.gz) file found for this iteration"
    # }
    
    scenario[[i]] <- data.table::fread(
      file = paste0(scenario_dir, "/", iter, ".events.csv.gz")
    )
      
    # scenario[[i]] <- events_file
  }
  
  scenario
  
}



#' Download data if not already present locally
#' 
#' @param get_from URI or similar to download from
#' @param save_to File to save locally
#' 
#' @return `TRUE` 
#' 
#' @export
#' 
get_if_needed <- function(get_from, save_to){
  if (!file.exists(save_to)){
    download.file(get_from, save_to)
    archive::archive_extract(save_to)
  }
}
