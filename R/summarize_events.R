############### Functions for summarizing the events files #####################

#' Gets total ridehail passengers
#' 
#' @param events Events file
#' @param veh_type Type of vehicle for ridehail
#' 
#' @return Total rh passengers
#' 
#' @export
#' 
get_tot_rh_passengers <- function(events, veh_type = "micro", iters){

  tot_passengers <- list()
  
  for (i in length(iters)){
    tot_passengers[[i]] <- sum(
      events[[i]][type == "PathTraversal" &
                    vehicleType == veh_type,
                  numPassengers])
  }

  tot_passengers
}
