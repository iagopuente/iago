# Set CRAN mirror to ensure package installations work from the appropriate repository
options(repos = c(CRAN = "https://cran.r-project.org"))

# Install RSQLite package if it is not already installed
install.packages("RSQLite", repos = "https://cran.r-project.org")

# Load the RSQLite library to interact with SQLite databases
library(RSQLite)

# Define the path to the processed data file, which contains stock data and news articles
processed_data_file <- "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/processed_data.RData"

# Check if the processed data file exists, and load it if it does
if (file.exists(processed_data_file)) {
  load(processed_data_file)
  
  # Define the list of stock tickers for the portfolio update
  tickers <- c("HSBA.L", "BP.L", "ULVR.L", "BARC.L", "LLOY.L")
  
  # Set the current date as the portfolio update date
  portfolio_date <- Sys.Date()
  
  # Define the path to the SQLite database file
  db_file <- "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/portfolio_update.db"
  
  # Establish a connection to the SQLite database, with error handling if connection fails
  conn <- tryCatch({
    dbConnect(RSQLite::SQLite(), db_file)
  }, error = function(e) {
    stop("Failed to connect to the database: ", e)
  })
  
  # Check if the Stock_Data table exists in the database, and create it if it doesn't
  if (!dbExistsTable(conn, "Stock_Data")) {
    dbExecute(conn, "CREATE TABLE Stock_Data (id INTEGER PRIMARY KEY AUTOINCREMENT, ticker TEXT, date TEXT, close_price REAL, percentage_change REAL)")
  }
  
  # Check if the News_Articles table exists in the database, and create it if it doesn't
  if (!dbExistsTable(conn, "News_Articles")) {
    dbExecute(conn, "CREATE TABLE News_Articles (id INTEGER PRIMARY KEY AUTOINCREMENT, headline TEXT, link TEXT, date TEXT)")
  }
  
  ### Insert stock data into the Stock_Data table for each ticker in the portfolio
  for (ticker in tickers) {
    # Check if stock data for the ticker exists and contains sufficient data
    if (!is.null(stock_data_list[[ticker]]) && nrow(stock_data_list[[ticker]]) > 1) {
      latest_price <- stock_data_list[[ticker]]$Close[1]  # Get the most recent closing price
      previous_price <- stock_data_list[[ticker]]$Close[2]  # Get the previous day's closing price
      percentage_change <- round(100 * (latest_price - previous_price) / previous_price, 2)  # Calculate percentage change
      
      # Insert the stock data into the Stock_Data table
      dbExecute(conn, "INSERT INTO Stock_Data (ticker, date, close_price, percentage_change) VALUES (?, ?, ?, ?)", 
                params = list(ticker, portfolio_date, latest_price, percentage_change))
    } else {
      cat("No data available for ticker:", ticker, "\n")  # Print message if no data is available for the ticker
    }
  }
  
  ### Insert news articles into the News_Articles table if there are any
  if (!is.null(bbc_news) && nrow(bbc_news) > 0) {
    for (i in 1:nrow(bbc_news)) {
      # Insert the news articles into the News_Articles table with the headline, link, and date
      dbExecute(conn, "INSERT INTO News_Articles (headline, link, date) VALUES (?, ?, ?)", 
                params = list(bbc_news$Headline[i], bbc_news$Link[i], portfolio_date))
    }
  } else {
    cat("No news data available.\n")  # Print message if no news articles are available
  }
  
  # Close the connection to the SQLite database
  dbDisconnect(conn)
  
} else {
  stop("Processed data file not found.")  # Print an error message if the processed data file is not found
}