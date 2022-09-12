####### Comparisons for preliminary analysis #######

compare_riders <- function(riders){
  
  scenarios <- names(riders)
  
  enters <- riders %>% 
    unlist() %>% 
    {.[names(.) %>%
         str_detect("enter")]}
  
  leaves <- riders %>% 
    unlist() %>% 
    {.[names(.) %>%
         str_detect("leave")]}
  
  comparison <- tibble(
    Scenario = scenarios,
    Entering = enters,
    Leaving = leaves
  )
  
  comparison
}



compare_utilization <- function(util){
  tibble(Scenario = names(util),
    Utilization = util)
}



comapre_wait_times <- function(wait){
  
}