library(ggcorrplot)
mtcars = read.table("test.csv") 
png("categories_compare.png",
    width     = 12,
    height    = 10,
    units     = "in",
    res       = 600,
    pointsize = 4)
# Compute a correlation matrix

#corr <- round(cor(mtcars), 3)
head(mtcars[, 1:6])
ggcorrplot(mtcars)
dev.off()
