# Ghibli R Web App

## Introduction
This application is built around the concept "Who has the time to read all the IMDb reviews?". This application aims to promote the wonderful films made by the Ghibli animation studio by condensing the reviews information on the IMDb website and obtaining the images and trailers about the selected movies automatically.

First the film titles and basic information are obtained using the Ghibli API. Using this information reviews were scraped from the IMDb movie reviews website. Some basic NLP techniques such as word clouds and N grams were used to summarise about 1500 user reviews. Also, the similarity between films was calculated based on the words within the reviews. Finally, the YouTube Data API was used to find the appropriate trailer for the movie automatically. 

## APIs Used
### Youtube Data API
* The movie trailers

### Ghibli API 
* Movie titles
* Information such as directors and producers

## Scraping
* IMDb Website
* Studio Ghibli Website

## Deployment
* Shiny App IO