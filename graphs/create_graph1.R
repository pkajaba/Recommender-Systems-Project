
rows <- read.csv("./length_category.csv", header = TRUE, sep = ",")

png("graph1.png",
    width     = 3.25,
    height    = 3.25,
    units     = "in",
    res       = 1200,
    pointsize = 4)
mar.default <- c(5,4,4,2) + 0.1
par(mar = c(11, 5, 2, 1)) 
plot (y = rows$length, x = rows$category, las=2, main = "Dĺžky vtipov podľa kategorií", ylab = "dĺžka vtipu v znakoch", pch = 1, cex = 1,col = "orange", type = "p",)
dev.off()
