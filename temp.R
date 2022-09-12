small <- function(csv){
  data.table::fread(csv)[
    order(person,time)][
      3000000:10000000
    ] %>% 
    data.table::fwrite(
      paste0(csv, "_small.csv.gz")
    )
}
