library(ggcorrplot)
png("user_similarities.png",
    width     = 12,
    height    = 10,
    units     = "in",
    res       = 600,
    pointsize = 4)
# Compute a correlation matrix
mtcars = read.table("user_similarities.txt") 
corr <- round(cor(mtcars), 3)
head(corr[, 1:6])
ggcorrplot(corr)
dev.off()
