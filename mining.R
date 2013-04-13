#text mining script for 
library(tm)

clean.corpus <- Corpus(VectorSource(test3$emailonly))
clean.corpus <- tm_map(clean.corpus, removePunctuation)
clean.corpus <- tm_map(clean.corpus, removeWords, stopwords('english'))
ctdm <- TermDocumentMatrix(clean.corpus, control=list(removePunctuation=TRUE,
                                                      removeNumbers = TRUE,
                                                      stopwords = TRUE))


#get frequency of words
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

days <- seq(as.Date("2012-04-26"), as.Date("2013-02-27"), by="1 day")
j <- setdiff(as.character(days), as.character(test2$date))
