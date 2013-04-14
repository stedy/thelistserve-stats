library("RSQLite")
conn <- dbConnect(SQLite(), dbname = "mail.db")
raw <- dbReadTable(conn, "mail")

#cleaning functions
raw$email <- sapply(strsplit(raw$payload, "Content-Length"), "[", 2)
raw$emailonly <- sapply(strsplit(raw$email, "Unsubscribe"), "[", 1)
raw$emailfull <- sapply(strsplit(raw$sender, '" <'), "[", 2)
raw$whom <- sapply(strsplit(raw$emailfull, "@"), "[", 1)
raw$date <- sapply(strsplit(raw$dt, " "), "[", 1)
raw$sender.name <- sapply(strsplit(raw$sender, '\\"'), "[", 2)
raw$date <- as.Date(raw$date)
raw$time <- sapply(strsplit(raw$dt, " "), "[", 2)

raw$subjclean <- sapply(strsplit(raw$subject, "Listserve=5D"), "[", 2)

raw.subjects <- gsub("=20", ' ', raw$subjclean)
raw.subjects <- gsub("?=", '', raw.subjects, fixed=TRUE)
raw.subjects <- gsub("=5B", '[', raw.subjects)
raw.subjects <- gsub("=2D", '-', raw.subjects)
raw.subjects <- gsub("=5D", ']', raw.subjects)
raw.subjects <- gsub("=27", "'", raw.subjects)
raw.subjects <- gsub("=28", "(", raw.subjects)
raw.subjects <- gsub("=29", ")", raw.subjects)
raw.subjects <- gsub("=21", '!', raw.subjects)
raw.subjects <- gsub("=3F", '?', raw.subjects)
raw.subjects <- gsub("=3A", ':', raw.subjects)
raw.subjects <- gsub("=2C", ',', raw.subjects)
raw.subjects <- gsub("=3B", ";", raw.subjects)
raw.subjects <- gsub("=E2=80=99", "'", raw.subjects)
raw.subjects <- gsub("=E2=80=9C", '"', raw.subjects)
raw.subjects <- gsub("=E2=80=9D", '"', raw.subjects)

#QC metrics
raw.datecheck <- raw[raw$date >= as.Date("2012-04-18"), ]
working <- raw.datecheck[!duplicated(raw.datecheck$sender), ]
working <- working[order(working$date), ]

dbDisconnect(conn)
