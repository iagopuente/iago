# Assignment 2: Automated Daily Stock Portfolio Update Pipeline

## Overview
In this project, I have automated the daily process of gathering stock data and financial news, processing and cleaning the data, storing it in a database, and sending a daily email with portfolio updates. The entire ETL process is automated using Windows Task Scheduler and involves various R scripts to manage different parts of the workflow.

## Files in the Repository

### 1. Bash Script
- **`run_etl.sh`**: This script orchestrates the entire ETL pipeline by executing four R scripts in sequence for:
  - API access
  - Web scraping
  - Data processing
  - Database storage
  - Email sending

### 2. R Scripts
- **`1_api_access.R`**: Fetches stock data from the Alpha Vantage API for five UK stocks from the FTSE 100 index.
  - **Key Changes**: Fetches the stock prices and stores them into an RData file (`stock_data_list.RData`) for further processing.
  
- **`2_web_scraping.R`**: Scrapes financial news articles from the BBC Business website.
  - **Key Changes**: The scraped data is stored into a data frame and saved into an RData file (`bbc_news.RData`).
  
- **`3_data_processing.R`**: Cleans and processes the stock data and news headlines (removes duplicates, handles missing values, etc.) and computes stock price percentage changes.
  - **Key Changes**: 
    - Includes a mapping between stock tickers and company names.
    - Stock summary now includes the company name, latest price, and percentage change (with "+" or "-" sign).
    - Saves processed stock data and news data into `processed_data.RData`.
  
- **`4_data_storage.R`**: Inserts the processed stock data and news headlines into an SQLite database (`portfolio_update.db`).
  - **Key Changes**: Handles creation of `Stock_Data` and `News_Articles` tables if they don't exist. Exports the data from the SQLite database to CSV for later use.
  
- **`send_email.R`**: Sends an email with the daily portfolio update.
  - **Key Changes**: The email body includes:
    - Stock summary with company names, latest prices, and percentage changes.
    - The news headlines with clickable links.
    - Adjusted stock summary to include "+" or "-" for percentage changes.
    - Subject line includes the current date.

- **`CSV export database.R`**: This script exports the database tables (`Stock_Data` and `News_Articles`) into CSV files for backup or further analysis.

### 3. Task Scheduler Configuration (PDF)
- **`task_scheduler_configuration.pdf`**: A step-by-step guide with screenshots showing how I set up Windows Task Scheduler to run the ETL process daily at 6 AM.

### 4. Database Export
- **`Stock_Data_Export.csv`**: A CSV export of the `Stock_Data` table from the SQLite database, including ticker, date, closing prices, and percentage changes.
- **`News_Articles_Export.csv`**: A CSV export of the `News_Articles` table from the SQLite database, including headlines, links, and the date.

## Setup Instructions

### 1. Prerequisites
- **Software**:
  - R installed on my system.
  - Required R packages: `httr`, `jsonlite`, `rvest`, `RSQLite`, `mailR`.
  - **Git Bash** or another terminal that supports `.sh` scripts (for running the Bash script).
  
- **Configuration**:
  - For sending email using Gmail, I must set up a **service-specific password** and update the credentials in the `send_email.R` script.

### 2. Running the ETL Pipeline Manually
1. **Open Git Bash** (or another terminal).
2. **Navigate to the directory** where my project is stored:
   ```bash
   cd "C:/Users/bolix/OneDrive - Universitat Ramón Llull/OneDrive Esade/Masters + GMAT/LBS/Subjects/Data Management/Assignment 2 - Automated Daily Stock Portfolio Update Pipeline"