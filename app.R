### Loading Libraries
library(tidyverse)
library(httr)
library(rvest)
library(jsonlite)
library(shiny)
library(shinythemes)
library(tidytext)
library(wordcloud)
library(DBI)
library(pool)
library(proxy)
library(tm)

### Sourcing
source("Database.R", local = TRUE) # Always source this file first as it connect to the DB
source("ghibliPortal.R", local = TRUE)
source("YouTubePortal.R", local = TRUE)
source("IMDbPortal.R", local = TRUE)
readRenviron(".Renviron")

ui <- fluidPage(theme = shinytheme("darkly"),
  tags$h1("Studio Ghibli Films"),
  sidebarPanel(
    selectInput(
      inputId = "film",
      label = "Film Name:",
      choices = getGhibliFilm("title")
    ),
    uiOutput("poster"),
    sliderInput(
      inputId = "wordcloud_max",
      label = "Word Cloud Max Words:",
      min = 100, max=500,
      value=2
    ),
    sliderInput(
      inputId = "ngram", 
      label = "Review N Grams:",
      min = 2, max=4,
      value=2, step=1
    ),
    sliderInput(
      inputId = "simfilm",
      label = "Similar Ghibli Films:",
      min = 3, max = 19,
      value=1, step=1
    ),
    tags$p("The similarity between films is calculated based the 
    words contained in the reviews for each of the films. It is 
    on a scale of 0 to 1, with 0 being the similar and 1 being the 
    most the unsimilar film.
    ")
  ),
  mainPanel(
    h2(textOutput("film")),
    
    imageOutput("screencapture"),
    
    fluidRow(
      tags$h3("Word Cloud"),
      plotOutput("wordcloud")
    ),
    
    fluidRow(
      column(6,
        tags$h3("N Grams"),
        tableOutput("n_gram")
      ),
      column(6,
        tags$h3("Similar Ghibli Films"),
        tableOutput("simfilm")
      )
    ),
    
    fluidRow(
      column(4,
        tags$h3("Film Information"),
        tags$p(uiOutput("director")),
        tags$p(uiOutput("producer")),
        tags$p(uiOutput("release_date")),
        textOutput("description")
      ),
      column(8,
        tags$h3("Trailer"),
        uiOutput("trailer")
      )
    ),
    
    fluidRow(
      tags$h3("IMDb User Review"),
      textOutput("IMDbReview")
    )
  ),
  
  ### Footer
  tags$div(class="container"),
  hr(),
  tags$p("Author: Shozen Dan"),
  tags$p("University of California Davis, Statistics"),
  tags$p("Keio University, Environmental and Information Sciences")
)

server <- function(input, output, session) {

  observeEvent(input$film, {
    # Display film title
    info <- getGhibliFilm(c("title", "director", "producer", "release_date", "description"))

    output$film <- renderText(input$film)

    output$director <- renderUI({
      name <- info %>%
        filter(title == input$film) %>%
        pull(director)
      HTML(paste("<b>Director</b>:", name))
    })

    output$producer <- renderUI({
      name <- info %>%
        filter(title == input$film) %>%
        pull(producer)
      HTML(paste("<b>Producer</b>:", name))
    })

    output$release_date <- renderUI({
      date <- info %>%
        filter(title == input$film) %>%
        pull(release_date)
      HTML(paste("<b>Release Date</b>:", date))
    })

    output$description <- renderText({
      info %>%
        filter(title == input$film) %>%
        pull(description)
    })

    # Get Trailer Video
    output$trailer <- renderUI({
      id <- searchVideo(input$film, "trailer")
      src <- paste0("https://www.youtube.com/embed/", id)
      return(tags$iframe(
        width = "100%",
        height = "330",
        src = src,
        frameborder = "0",
        allow = "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
        allowfullscreen = NA
      ))
    })
    
    output$simfilm <- renderTable({
      getSimilarFilm(input$film, input$simfilm)
    })
    
    # Display Word Cloud
    output$wordcloud <- renderPlot({
      generateWordCloud(input$film, input$wordcloud_max)
    })
    
    # Display N gram
    output$n_gram <- renderTable({
      title <- input$title
      n <- input$ngram
      getNGram(title, n)
    })

    # Display film poster
    output$poster <- renderUI({
      src <- ghibli.images %>% 
        filter(title == input$film) %>% 
        pull(link)
      return(tags$img(
        width = "223",
        height = "300",
        src = src,
        alt = "Poster Image",
      ))
    })
    
    # Displays a IMDb Review
    output$IMDbReview <- renderText({
      review <- getIMDbReview(input$film)
      review$reviewText
    })

    # Display Meta Critic
    output$meta.critic <- renderPlot({
      review <- getIMDbReview(input$film)
      criticBarPlot(review[["id"]])
    })
  })

  # Render Screen Capture
  output$screencapture <- renderImage(
    {
      PATH <- "./www/GhibliArt/"
      screencapture <- list(
        "Castle in the Sky" = "castle_in_the_sky.jpg",
        "Grave of the Fireflies" = "grave_fireflies.jpg",
        "My Neighbor Totoro" = "neighbor_totoro.jpg",
        "Kiki's Delivery Service" = "kiki_delivery.jpg",
        "Only Yesterday" = "only_yesterday.jpg",
        "Porco Rosso" = "porco_rosso",
        "Pom Poko" = "pompoko",
        "Whisper of the Heart" = "whisper_of_the_heart.jpg",
        "Princes Mononoke" = "mononoke.jpg",
        "My Neighbors the Yamadas" = "yamadas.png",
        "Spirited Away" = "spirited_away.jpg",
        "The Cat Returns" = "cat_returns.jpg",
        "Howl's Moving Castle" = "howls_moving_castle.jpg",
        "Tales from Earthsea" = "earthsea.jpg",
        "Ponyo" = "ponyo_poster.jpg",
        "Arrietty" = "arrietty.jpg",
        "From Up on Poppy Hill" = "poppy_hill.jpg",
        "The Wind Rises" = "the_wind_rises.jpg",
        "The Tale of the Princess Kaguya" = "kaguya.jpg",
        "When Marnie Was There" = "marnie.png"
      )
      list(
        src = paste0(PATH, screencapture[[input$film]]),
        width = "100%",
        height = "100%"
      )
    },
    deleteFile = FALSE
  )
  
  # render logo
  output$ghibli.logo <- renderImage({
    list(
      src = "./www/ghibli_logo.png",
      alt = "Ghibli Logo",
      width = "100%"
    )
  }, deleteFile = FALSE)
}

shinyApp(ui, server)