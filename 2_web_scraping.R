# Set CRAN mirror for package installation
options(repos = c(CRAN = "https://cran.r-project.org"))

# Install the 'rvest' package (for web scraping) if it is not already installed
if(!require("rvest")) install.packages("rvest", dependencies=TRUE)

# Load the 'rvest' library for web scraping functionality
library(rvest)

# Define the URL of the BBC Business page, which will be scraped for news headlines and links
url <- "https://www.bbc.co.uk/news/business"

# Fetch and parse the HTML content of the BBC Business page
page <- read_html(url)

### Web Scraping Section ###
# Extract the news headlines using the appropriate CSS selector
# The 'html_nodes' function is used to identify nodes that match the CSS class for headlines.
# 'html_text' retrieves the actual text content of those nodes, with 'trim = TRUE' to remove extra spaces.
headlines <- page %>%
  html_nodes(".ssrcss-1sen9vx-PromoHeadline") %>%
  html_text(trim = TRUE)

# Extract the corresponding links for each headline using another CSS selector
# 'html_attr' is used to retrieve the 'href' attribute, which contains the link for each article.
links <- page %>%
  html_nodes(".ssrcss-1mrs5ns-PromoLink") %>%
  html_attr("href")

# Convert relative links to absolute URLs by appending the BBC base URL
links <- paste0("https://www.bbc.co.uk", links)

# Ensure that the number of headlines matches the number of links
# The 'min_length' variable is used to determine the smaller of the two counts (headlines and links)
# to avoid mismatches when combining them into a data frame
min_length <- min(length(headlines), length(links))

# Combine the extracted headlines and links into a data frame for easier processing
bbc_news <- data.frame(Headline = headlines[1:min_length], Link = links[1:min_length], stringsAsFactors = FALSE)

### Validation Section ###
# Check if any headlines and links were found during the scraping process.
# If none are found, print a message indicating that no articles were found.
if(nrow(bbc_news) == 0) {
  cat("No news articles found. \n")
} else {
  # If articles are found, print a success message indicating that the scraping was successful.
  cat("News articles successfully scraped. \n")
}

### Create a Summary for Email ###
# Create a formatted summary of the news articles to be included in the email body.
# Each news article will be listed with its index number, headline, and link in the following format:
# "1. Headline - Link"
news_summary <- paste(
  seq_along(bbc_news$Headline),  # Index numbers for each article
  bbc_news$Headline,             # The actual news headline
  "-",                           # Separator between headline and link
  bbc_news$Link,                 # Corresponding link for each headline
  collapse = "\n"                # Separate each news item by a newline in the final string
)

# Save the scraped news data (bbc_news) and the formatted summary (news_summary) to an RData file
# This allows the data to be loaded and reused in other parts of the ETL process, such as sending an email.
save(bbc_news, news_summary, file = "bbc_news.RData")