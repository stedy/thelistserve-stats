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

#QC metrics
test2 <- raw[raw$date >= as.Date("2012-04-25"), ]
test3 <- test2[!duplicated(test2$sender), ]

dbDisconnect(conn)
