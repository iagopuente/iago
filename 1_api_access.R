# Set CRAN mirror for package installation
options(repos = c(CRAN = "https://cran.r-project.org"))

# Install necessary packages (httr and jsonlite) to make HTTP requests and handle JSON data
install.packages("httr")
install.packages("jsonlite")

# Load required libraries
library(httr)      # For making HTTP requests to the Alpha Vantage API
library(jsonlite)  # For parsing JSON responses from the API

# Set my Alpha Vantage API key 
api_key <- "PBDTV88B4RZ64CRK"

# Function to fetch stock data from Alpha Vantage, with retry logic and rate limiting
fetch_stock_data_alpha <- function(ticker, max_retries = 3) {
  # Construct the API request URL with the stock ticker and API key
  url <- paste0("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=", ticker, "&apikey=", api_key)
  
  # Loop to retry the API request up to 'max_retries' times in case of errors
  for (attempt in 1:max_retries) {
    # Make the GET request to Alpha Vantage API
    response <- GET(url)
    
    # Check if the API request was successful (status 200)
    if (status_code(response) == 200) {
      # Parse the JSON response
      data <- fromJSON(content(response, "text"))
      
      # Check if time series data is available
      if (!is.null(data$`Time Series (Daily)`)) {
        time_series <- data$`Time Series (Daily)`
        
        # Extract the dates and closing prices
        dates <- names(time_series)
        closes <- sapply(time_series, function(x) x$`4. close`)
        
        # Create a data frame with the extracted stock data
        stock_data <- data.frame(Date = as.Date(dates), Close = as.numeric(closes), stringsAsFactors = FALSE)
        return(stock_data)  # Return the stock data as a data frame
      } else {
        # Return a warning message if no time series data is found for the stock
        warning_msg <- paste("No time series data found for", ticker)
        return(warning_msg)
      }
    } else {
      # Handle rate limiting errors (status 429) by waiting and retrying
      if (status_code(response) == 429) {
        message("Rate limit hit, retrying in 60 seconds...")
        Sys.sleep(60)  # Wait for 60 seconds before retrying
      } else {
        # Return an error message if the request fails for other reasons
        return(paste("Error fetching data for", ticker, ": ", status_code(response)))
      }
    }
  }
  
  # Return a final error message if all retries fail
  return(paste("Failed to fetch data for", ticker, "after", max_retries, "attempts."))
}

# List of tickers for which data will be fetched (London Stock Exchange)
tickers <- c("HSBA.L", "BP.L", "ULVR.L", "BARC.L", "LLOY.L")

# Initialize an empty list to store the stock data for each ticker
stock_data_list <- list()

# Initialize variables to keep track of API request counts and the daily limit
request_count <- 0
daily_limit <- 25  # Free API limit for Alpha Vantage

# Loop through each stock ticker and fetch its data, respecting rate limits
for (ticker in tickers) {
  # Stop the process if the daily API limit is reached
  if (request_count >= daily_limit) {
    message("Daily API limit reached. Exiting the process.")
    break
  }
  
  # Fetch the stock data using the function
  stock_data <- fetch_stock_data_alpha(ticker)
  stock_data_list[[ticker]] <- stock_data  # Store the data in the list
  
  # Increment the request count and pause to avoid hitting the API rate limit (5 requests per minute)
  request_count <- request_count + 1
  Sys.sleep(15)  # Pause for 15 seconds between requests
}

# Save the fetched stock data to a file for later use
save(stock_data_list, file = "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/stock_data_list.RData")