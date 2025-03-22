# Load the RSQLite package to interact with SQLite databases
library(RSQLite)

# Connect to the SQLite database where stock data and news articles are stored
# The path points to the database file where the data is saved
conn <- dbConnect(RSQLite::SQLite(), 
                  "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/portfolio_update.db")

### Export Stock Data ###
# Run a SQL query to fetch all records from the "Stock_Data" table
# This contains information about stock tickers, closing prices, and percentage changes
stock_data <- dbGetQuery(conn, "SELECT * FROM Stock_Data")

# Write the fetched stock data into a CSV file named "Stock_Data_Export.csv"
# The file will be saved without row numbers
write.csv(stock_data, "Stock_Data_Export.csv", row.names = FALSE)

### Export News Articles ###
# Run a SQL query to fetch all records from the "News_Articles" table
# This contains business news headlines, links, and the dates they were published
news_articles <- dbGetQuery(conn, "SELECT * FROM News_Articles")

# Write the fetched news articles into a CSV file named "News_Articles_Export.csv"
# The file will be saved without row numbers
write.csv(news_articles, "News_Articles_Export.csv", row.names = FALSE)

# Close the connection to the SQLite database to release resources
dbDisconnect(conn)