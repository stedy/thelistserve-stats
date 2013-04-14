#text mining script for The Listserve
library(tm)
library(chron)

#determine names
names <- data.frame(table(working$sender.name))
names <- names[order(names[, 2], decreasing=TRUE), ]
write.table(names, "names_table.txt", row.names = F, col.names=F, quote=F)

working$first.names <- sapply(strsplit(as.character(working$sender.name), "\\ "), "[", 1)
first.names <- data.frame(table(working$first.names))
first.names <- first.names[order(first.names[, 2], decreasing=TRUE), ]

#time sent

arrival.times <- times(working$time)
pdf("arrivaltimes.pdf", width=17, height=17)
plot.ts(arrival.times, main="Arrival times based on UTC")
abline(h=mean(arrival.times), col="red")
dev.off()

#first try cleaning subject line

subject.corpus <- Corpus(VectorSource(raw.subjects))
subject.corpus <- tm_map(subject.corpus, removePunctuation)
subject.corpus <- tm_map(subject.corpus, removeWords, stopwords('english'))
subject.ctdm <- TermDocumentMatrix(subject.corpus, control=list(removePunctuation=TRUE,
                                                      removeNumbers = TRUE,
                                                      stopwords = TRUE))
subject.ctdm.m <- as.matrix(subject.ctdm)
word.freqs.subject <- sort(rowSums(subject.ctdm.m), decreasing=TRUE) 

# create a data frame with subject words and their frequencies
subj.dm <- data.frame(word=names(word.freqs.subject), freq=word.freqs.subject)

#then repeat for the body of the email
clean.corpus <- Corpus(VectorSource(working$emailonly))
clean.corpus <- tm_map(clean.corpus, removePunctuation)
clean.corpus <- tm_map(clean.corpus, removeWords, stopwords('english'))
ctdm <- TermDocumentMatrix(clean.corpus, control=list(removePunctuation=TRUE,
                                                      removeNumbers = TRUE,
                                                      stopwords = TRUE))
#get frequency of words from body
ctdm.m <- as.matrix(ctdm)
word.freqs <- sort(rowSums(ctdm.m), decreasing=TRUE) 

# create a data frame with words and their frequencies
dm <- data.frame(word=names(word.freqs), freq=word.freqs)

ctdm2 <- removeSparseTerms(ctdm, sparse=0.95)
pdf("findFreqall.pdf", width=37, height=37)
plot(ctdm2, terms = findFreqTerms(ctdm2, lowfreq = 6), corThreshold = 0.5)
dev.off()


mydata.df <- as.data.frame(inspect(ctdm2))
mydata.df.scale <- scale(mydata.df)
d <- dist(mydata.df.scale, method = "euclidean") # distance matrix
pdf("dendrogram.pdf", width=17, height=17)
fit <- hclust(d, method="ward")
plot(fit)
dev.off()  

days <- seq(as.Date("2012-04-18"), as.Date("2013-04-13"), by="1 day")
j <- setdiff(as.character(days), as.character(raw.datecheck$date))
