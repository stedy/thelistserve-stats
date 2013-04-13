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
raw$subjclean <- sapply(strsplit(raw$subject, "Listserve=5D"), "[", 2)

test1 <- gsub("=20", ' ', raw$subjclean)
test1 <- gsub("?=", '', test1, fixed=TRUE)
test1 <- gsub("=5B", '[', test1)
test1 <- gsub("=2D", '-', test1)
test1 <- gsub("=5D", ']', test1)
test1 <- gsub("=27", "'", test1)
test1 <- gsub("=28", "(", test1)
test1 <- gsub("=29", ")", test1)
test1 <- gsub("=21", '!', test1)
test1 <- gsub("=3F", '?', test1)
test1 <- gsub("=3A", ':', test1)
test1 <- gsub("=2C", ',', test1)
test1 <- gsub("=3B", ";", test1)
test1 <- gsub("=E2=80=99", "'", test1)
test1 <- gsub("=E2=80=9C", '"', test1)
test1 <- gsub("=E2=80=9D", '"', test1)

#QC metrics
test2 <- raw[raw$date >= as.Date("2012-04-25"), ]
test3 <- test2[!duplicated(test2$sender), ]

dbDisconnect(conn)
