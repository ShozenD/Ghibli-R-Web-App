# Connects to the Google postgre SQL database
#
# return None
connectDB <- function() {
  print("Establishing connection...")
  host <- "35.222.141.134"
  return(
    pool::dbPool(
      RPostgres::Postgres(),
      dbname = "ghibli-app-database",
      user = "postgres", password = Sys.getenv("DATABASEPW"), host = host,
      sslmode = "disable"
      #gssencmode = "disable"
    )
  )
  print("...Established!")
}

# Writes a table to the databbase (for maintainance purposes only)
#
# @param tbl the table to write to database
# @param name the desired table name
#
# return None
writeDB <- function(tbl, name, overwrite=TRUE) {
  if(is.null(mydb)){
    print("Establishing connection...")
    mydb <- connectDB()
  }
  DBI::dbWriteTable(mydb, name, tbl)
  print("...Complete!")
}

# Connect to database
mydb <- connectDB()

