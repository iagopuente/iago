# Set CRAN mirror to ensure package installations work correctly
options(repos = c(CRAN = "https://cran.r-project.org"))

# Install the mailR package for sending emails if it's not already installed
if (!require(mailR)) {
  install.packages("mailR", repos = "https://cran.r-project.org")
}
library(mailR)

# Specify a log file to capture the output of the email sending process
log_file <- "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/deadline_email_log.txt"

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
  
  # Construct the email body with stock summary and news articles
  email_body <- paste(
    "Assignment 2 Submission:\n\n",           # Email greeting
    "Stock Summary:\n",                      # Section for stock summary
    paste(stock_summary, collapse = "\n"),   # Join all stock summaries into a single string
    "\n\nToday's News:\n",                   # Section for news
    paste(paste0(seq_along(bbc_news$Headline), ". ", bbc_news$Headline, " - ", bbc_news$Link), collapse = "\n"),  # News list
    sep = ""                                 # Concatenate everything into the final email body
  )
  
  # Debugging: Print the constructed email body to verify the content
  print(email_body)
  
  # Define the files to attach (the 4 R scripts, bash script, and task scheduler PDF)
  files_to_attach <- c(
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/1_api_access.R",
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/2_web_scraping.R",
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/3_data_processing.R",
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/4_data_storage.R",
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/run_etl.sh",
    "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline/task_scheduler_configuration.pdf"
  )
  
  # Send the email using Gmail's SMTP server to the professor, with attachments
  tryCatch({
    send.mail(
      from = "iago.puente@gmail.com",                      # Sender's email address
      to = "iago.puente@gmail.com",                          # Professor's email address
      subject = "your_student_number, assignment2",         # Correct subject format
      body = email_body,                                   # Email body created above
      smtp = list(                                         # SMTP server settings for Gmail
        host.name = "smtp.gmail.com",                      # Gmail's SMTP host
        port = 587,                                        # Port number for TLS
        user.name = "iago.puente@gmail.com",               # Sender's email
        passwd = "yqqm rleu vacg ozln",                    # Email password (replace with a secure method)
        ssl = TRUE                                         # Enable SSL for a secure connection
      ),
      authenticate = TRUE,                                 # Enable SMTP authentication
      send = TRUE,                                         # Send the email
      attach.files = files_to_attach                       # Attach the required files
    )
    # If email is sent successfully, log the success message
    message("Deadline email sent successfully to jfrancis@london.edu.")
  }, error = function(e) {
    # If email sending fails, log the error message
    message("Failed to send deadline email: ", e)
  })
  
} else {
  # Log a message if the processed data file was not found
  message("Processed data file not found for deadline email.")
}

# Stop logging the output to the log file
sink()