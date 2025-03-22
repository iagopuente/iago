#!/bin/bash

# Define paths
R_SCRIPT_PATH="/c/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline"
LOG_FILE="$R_SCRIPT_PATH/etl_log.txt"
RSCRIPT_PATH="/c/Program Files/R/R-4.4.1/bin/Rscript.exe"

# Start Logging
echo "ETL Process Started: $(date)" > "$LOG_FILE"

# Run API Access Script
echo "Running API Access Script..." >> "$LOG_FILE"
"$RSCRIPT_PATH" "$R_SCRIPT_PATH/1_api_access.R" >> "$LOG_FILE" 2>&1
echo "API Access Script Finished" >> "$LOG_FILE"

# Run Web Scraping Script
echo "Running Web Scraping Script..." >> "$LOG_FILE"
"$RSCRIPT_PATH" "$R_SCRIPT_PATH/2_web_scraping.R" >> "$LOG_FILE" 2>&1
echo "Web Scraping Script Finished" >> "$LOG_FILE"

# Run Data Processing Script
echo "Running Data Processing Script..." >> "$LOG_FILE"
"$RSCRIPT_PATH" "$R_SCRIPT_PATH/3_data_processing.R" >> "$LOG_FILE" 2>&1
echo "Data Processing Script Finished" >> "$LOG_FILE"

# Run Data Storage Script
echo "Running Data Storage Script..." >> "$LOG_FILE"
"$RSCRIPT_PATH" "$R_SCRIPT_PATH/4_data_storage.R" >> "$LOG_FILE" 2>&1
echo "Data Storage Script Finished" >> "$LOG_FILE"

# Run Email Sending Script
echo "Running Email Sending Script..." >> "$LOG_FILE"
"$RSCRIPT_PATH" "$R_SCRIPT_PATH/send_email.R" >> "$LOG_FILE" 2>&1
echo "Email Sending Script Finished" >> "$LOG_FILE"

# End Logging
echo "ETL Process Finished: $(date)" >> "$LOG_FILE"