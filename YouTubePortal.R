searchVideo <- function(title, param) {
  # Gets the ID of the first video that matches the search params
  search_string <- paste(title, param)
  res <- GET("https://www.googleapis.com/youtube/v3/search?",
    query = list(
      key = Sys.getenv("GOOGLE_API_KEY"),
      part = "snippet",
      q = search_string,
      maxResults = 1
    )
  )
  stop_for_status(res)
  json <- httr::content(res, as = "text", encoding = "UTF-8")
  result <- fromJSON(json, flatten = TRUE)
  id <- result$items %>% pull(id.videoId)
  return(id)
}

getVideoStats <- function(id) {
  # Gets the statistics of a certain video by specifying its id
  res <- GET("https://www.googleapis.com/youtube/v3/videos?",
    query = list(
      key = Sys.getenv("GOOGLE_API_KEY"),
      part = "statistics",
      id = id
    )
  )
  stop_for_status(res)
  json <- httr::content(res, as = "text", encoding = "UTF-8")
  result <- fromJSON(json, flatten = TRUE)
  video.stats <- as.data.frame(result$items) %>%
    select(
      statistics.viewCount,
      statistics.likeCount,
      statistics.dislikeCount,
      statistics.commentCount
    )
  return(video.stats)
}

getVideoComments <- function(id) {
  res <- GET("https://www.googleapis.com/youtube/v3/commentThreads?",
    query = list(
      key = Sys.getenv("GOOGLE_API_KEY"),
      part = "snippet",
      part = "replies",
      maxResults = 100,
      videoId = id
    )
  )
  stop_for_status(res)
  json <- httr::content(res, as = "text", encoding = "UTF-8")
  result <- fromJSON(json, flatten = TRUE)
  return(result)
}
