library(DBI)
library(httr)
library(rvest)
library(jsonlite)

host <- "35.222.141.134"

### Connect to database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "ghibli-app-database",
  user = "postgres", password = Sys.getenv("DATABASEPW"), host = host,
  sslmode = "disable"
)

### Helper functions
getGhibliFilm <- function(list) {
  ghibli.films.endpoint <- "https://ghibliapi.herokuapp.com/films"
  films <- fromJSON(ghibli.films.endpoint)
  info <- films %>% select(list)
  return(info)
}

getIMDbReview <- function(title) {
  q <- str_replace_all(title, "\\s", "+")
  search.html <- read_html(str_glue("https://www.imdb.com/find?q={q}", q = q))
  link <- search.html %>%
    html_node("td.result_text") %>%
    html_node("a") %>%
    html_attr("href")

  movie.html <- read_html(paste0("https://www.imdb.com", link))

  rating <- movie.html %>%
    html_node("div.imdbRating") %>%
    html_node("span") %>%
    html_text()

  rating.count <- movie.html %>%
    html_node("div.imdbRating") %>%
    html_node("span.small") %>%
    html_text()

  review.text <- movie.html %>%
    html_node("div.user-comments") %>%
    html_node("span") %>%
    html_node("p") %>%
    html_text()

  id <- link %>%
    str_match("/title/[a-zA-Z0-9]+/") %>%
    as.vector()

  return(
    list(
      "id" = id,
      "rating" = rating,
      "ratingCount" = rating.count,
      "reviewText" = review.text
    )
  )
}

### Scraping reviews
film.titles <- pull(getGhibliFilm("title"), title)
info <- map(film.titles, getIMDbReview)

endpoints <- map_chr(info, ~ {
  paste0("https://www.imdb.com", .$id, "reviews?")
})

tbl.title.end <- tibble(
  endpoint = endpoints,
  title = film.titles
)

reviews.df.list <- endpoints %>%
  map(~ {
    endpoint <- .
    df.list <- list()

    for (i in 7:10) {
      Sys.sleep(1)
      res <- GET(endpoint,
        query = list(
          sort = "helpfulnessScore",
          dir = "desc",
          ratingFilter = i
        )
      )
      page <- read_html(res)
      reviews <- page %>%
        html_nodes("div.text") %>%
        html_text()
      df.reviews <- tibble(endpoint = endpoint, rating = i, review = reviews)
      df.list[[i - 6]] <- df.reviews
    }
    bind_rows(df.list)
  })

df.reviews <- bind_rows(reviews.df.list)
df.reviews <- left_join(df.reviews, tbl.title.end)
df.reviews$id <- 1:nrow(df.reviews)

### Update the database
dbWriteTable(con, "IMDb.Ghibli.Reviews", df.reviews, overwrite = TRUE)

dbDisconnect(con)
