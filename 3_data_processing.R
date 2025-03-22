# Load the saved stock data from the previously executed API access script
# This RData file contains the stock prices for the tickers
load("C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/stock_data_list.RData")

# Load the saved BBC news data from the web scraping script
# This file contains the headlines and links for business-related news articles
load("C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/bbc_news.RData")

# List of stock tickers being tracked (all from the London Stock Exchange)
tickers <- c("HSBA.L", "BP.L", "ULVR.L", "BARC.L", "LLOY.L")

### Data Cleanup Section ###

# Remove rows where either the headline or the link is missing (NA values)
bbc_news <- bbc_news[!is.na(bbc_news$Headline) & !is.na(bbc_news$Link), ]

# Remove any duplicate headlines, ensuring that each headline appears only once
bbc_news <- bbc_news[!duplicated(bbc_news$Headline), ]

# Clean up the headlines by removing extra spaces, ensuring a uniform format
bbc_news$Headline <- gsub("\\s+", " ", bbc_news$Headline)

### Daily Portfolio Update Section ###

# Set the date for the current portfolio update; this will usually be the current date
portfolio_date <- Sys.Date()

# Mapping of stock tickers to company names
company_names <- list(
  "HSBA.L" = "HSBC Holdings",
  "BP.L" = "BP plc",
  "ULVR.L" = "Unilever plc",
  "BARC.L" = "Barclays plc",
  "LLOY.L" = "Lloyds Banking Group"
)

# Create a summary of the stock data for each ticker
# For each stock ticker, the script extracts the most recent (latest) and the previous closing price
# It then calculates the percentage change and formats the result in a readable way
stock_summary <- sapply(tickers, function(ticker) {
  # Check if stock data for the given ticker exists and contains more than one row of data
  if (!is.null(stock_data_list[[ticker]]) && nrow(stock_data_list[[ticker]]) > 1) {
    latest_price <- stock_data_list[[ticker]]$Close[1]  # Most recent closing price
    previous_price <- stock_data_list[[ticker]]$Close[2]  # Previous day's closing price
    percentage_change <- round(100 * (latest_price - previous_price) / previous_price, 2)  # Percentage change
    
    # Determine the percentage change symbol (+ or -)
    change_symbol <- ifelse(percentage_change >= 0, "+", "")
    
    # Format the result with the company name, ticker, and price information
    paste(company_names[[ticker]], "(", gsub(".L", "", ticker), "):", 
          sprintf("£%.2f", latest_price), paste0("(", change_symbol, percentage_change, "%)"))
  } else {
    # If no data is available for the ticker, return a message indicating so
    paste(company_names[[ticker]], "(", gsub(".L", "", ticker), "): No data available")
  }
})

# Print the stock summary to the console for verification
# This is useful for debugging or checking the data during script execution
print(stock_summary)

### Save Processed Data Section ###

# Save the processed data into an RData file for use in other parts of the ETL pipeline (e.g., email sending)
# This saves the stock data list, the portfolio update date, the stock summary, and the cleaned BBC news data
save(stock_data_list, portfolio_date, stock_summary, bbc_news, 
     file = "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/processed_data.RData")