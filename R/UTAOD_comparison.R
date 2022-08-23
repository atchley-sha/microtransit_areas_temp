######## Compare UTA On Demand to BEAM ##############

#' Pivots UTA On Demand info to have months as columns
#' 
#' @param UTAOD UTA On Demand info
#'
#' @export
#'
pivot_uta <- function(UTAOD){
  
  ridership <- mean(UTAOD$`Avg wkday ridership`)
  util <- mean(UTAOD$Utilization)
  wait <- mean(UTAOD$`Avg wait time`)
  
  UTAOD %>% 
    pivot_longer(-Month) %>% 
    pivot_wider(names_from = Month) %>% 
    rename(" " = name,
           January = JAN,
           February = FEB,
           March = MAR) %>% 
    add_column(Mean = c(ridership, util, wait))
}


compare_existing <- function(UTA, iters, riders, util, wait){
  
  beam_results <- tibble(
    " " = c("Avg wkday ridership",
                           "Utilization",
                           "Avg wait time"))
  
  for(i in iters){
    
    col <- as.character(i)
    
    beam_results <- beam_results %>% 
      add_column(c(riders[[col]], util[[col]], wait[[col]]$quantiles["50%"]),
                 .name_repair = "universal")
  }
  
  colnames(beam_results) <- c(" ", as.character(iters))
  
  comparison <- left_join(UTA, beam_results, by = " ")
  comparison
  
}