# Set CRAN mirror to ensure package installations work correctly
options(repos = c(CRAN = "https://cran.r-project.org"))

# Install the mailR package for sending emails if it's not already installed
if (!require(mailR)) {
  install.packages("mailR", repos = "https://cran.r-project.org")
}
library(mailR)

# Specify a log file to capture the output of the email sending process
log_file <- "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/email_log.txt"

# Start logging output to the specified log file
sink(log_file, append = TRUE)

# Load the processed data (stock_summary, news articles, etc.) from a pre-saved RData file
data_file <- "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/processed_data.RData"

# Check if the processed data file exists before attempting to load it
if (file.exists(data_file)) {
  load(data_file)
  
  # Debugging: Print the loaded data to verify everything is correct
  print("Loaded processed data:")
  print(stock_summary)  # Print stock summary for debugging purposes
  print(bbc_news)       # Print BBC news headlines for debugging purposes
  
  # Adjust the stock summary to include "+" or "-" for percentage changes
  # The script parses the percentage change from the summary and adds the "+" sign for positive changes
  stock_summary <- sapply(stock_summary, function(summary) {
    # Extract the percentage change from the summary string using regex
    percentage_change <- as.numeric(gsub(".*\\(([-+]?[0-9.]+)%\\).*", "\\1", summary))
    
    # Modify the summary to show "+" for positive values and "-" for negative
    if (percentage_change > 0) {
      sub("\\([^)]+\\)", paste0("(+", percentage_change, "%)"), summary)
    } else {
      sub("\\([^)]+\\)", paste0("(", percentage_change, "%)"), summary)
    }
  })
  
  # Construct the email body with stock summary and news articles
  email_body <- paste(
    "Daily Portfolio Update:\n\n",           # Email greeting
    "Stock Summary:\n",                      # Section for stock summary
    paste(stock_summary, collapse = "\n"),   # Join all stock summaries into a single string
    "\n\nToday's News:\n",                   # Section for news
    paste(paste0(seq_along(bbc_news$Headline), ". ", bbc_news$Headline, " - ", bbc_news$Link), collapse = "\n"),  # News list
    sep = ""                                 # Concatenate everything into the final email body
  )
  
  # Debugging: Print the constructed email body to verify the content
  print(email_body)
  
  # Send the email using Gmail's SMTP server
  tryCatch({
    send.mail(
      from = "iago.puente@gmail.com",                      # Sender's email address
      to = "iago.puente@gmail.com",                        # Recipient's email address
      subject = paste("Daily Portfolio Update -", Sys.Date()),  # Include current date in the email subject
      body = email_body,                                   # Email body created above
      smtp = list(                                         # SMTP server settings for Gmail
        host.name = "smtp.gmail.com",                      # Gmail's SMTP host
        port = 587,                                        # Port number for TLS
        user.name = "iago.puente@gmail.com",               # Sender's email
        passwd = "yqqm rleu vacg ozln",                    # Email password (replace with a secure method)
        ssl = TRUE                                         # Enable SSL for a secure connection
      ),
      authenticate = TRUE,                                 # Enable SMTP authentication
      send = TRUE                                          # Send the email
    )
    # If email is sent successfully, log the success message
    message("Email sent successfully.")
  }, error = function(e) {
    # If email sending fails, log the error message
    message("Failed to send email: ", e)
  })
  
} else {
  # Log a message if the processed data file was not found
  message("Processed data file not found.")
}

# Stop logging the output to the log file
sink()