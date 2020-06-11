# Obtains ghibli film information using the Ghibli API
#
# @params list a list of columns to be included in the output data frame. 
#         Valid choices are "title", "description", "director", "producer", "release_date", "rt_score"
#
# return a dataframe
getGhibliFilm <- function(list) {
  # returns a dataframe of specified film info
  ghibli.films.endpoint <- "https://ghibliapi.herokuapp.com/films"
  films <- fromJSON(ghibli.films.endpoint)
  info <- films %>% select(list)
  return(info)
}

# loading the information from database
ghibli.images <- collect(tbl(mydb, "Ghibli.Posters"))




