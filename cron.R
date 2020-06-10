### Scrape reviews
film.titles <- getGhibliFilm("title")
info <- map(pull(film.titles, title), getIMDbReview)

endpoints <- map_chr(info, ~{paste0(IMDb.root.link, .$id, "reviews?")})
tbl.title.end <- tibble(endpoint = endpoints, title = pull(film.titles, title))

list.df.reviews <- endpoints %>%
  map(~ {
    endpoint <- .
    df.list <- list()
    
    for (i in 7:10) {
      Sys.sleep(1) # trying to avoid becoming a DOS attack
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
      df.list[[i-6]] <- df.reviews
    }
    
    bind_rows(df.list)
  })

df.reviews <- bind_rows(list.df.reviews)
df.reviews <- left_join(df.reviews, tbl.title.end)
df.reviews$id <- 1:nrow(df.reviews)