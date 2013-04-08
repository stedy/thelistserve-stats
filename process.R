library("RSQLite")
#conn <- dbConnect(SQLite(), dbname="../LS/thelistserve-stats/mail.db")
conn <- dbConnect(SQLite(), dbname = "mail.db")
test <- dbReadTable(conn, "mail")

test$email <- sapply(strsplit(test$payload, "Content-Length"), "[", 2)
test$emailonly <- sapply(strsplit(test$email, "Unsubscribe"), "[", 1)
test$emailfull <- sapply(strsplit(test$sender, '" <'), "[", 2)
test$whom <- sapply(strsplit(test$emailfull, "@"), "[", 1)
test$date <- sapply(strsplit(test$dt, " "), "[", 1)
test$sender.name <- sapply(strsplit(test$sender, '\\"'), "[", 2)
test$date <- as.Date(test$date)
test2 <- test[test$date >= as.Date("2012-04-25"), ]
test3 <- test2[!duplicated(test2$sender), ]

dbDisconnect(conn)