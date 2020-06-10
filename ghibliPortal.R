getGhibliFilm <- function(list) {
  # returns a dataframe of specified film info
  ghibli.films.endpoint <- "https://ghibliapi.herokuapp.com/films"
  films <- fromJSON(ghibli.films.endpoint)
  info <- films %>% select(list)
  return(info)
}

ghibli.images <- collect(tbl(mydb, "Ghibli.Posters"))




