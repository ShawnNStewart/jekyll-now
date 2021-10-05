---
layout: plot
title: R Exercises - Anscombe's Quartet
---
Anscombe’s Quartet clearly and cleverly shows why it is essential to view your data (as in, create a data visualization to explore it). Just looking at lists of numbers, or even the descriptive statistics for the dataset, cannot give us a complete understanding of the patterns in the data. For that, we need visualization. 

Anscombe created four sets of data that have almost identical summary statistics and linear regressions. However, when the datasets are plotted it quickly becomes evident that there are four distinct patterns. One is a curvilinear relationship, one is a perfect linear relationship except for one outlier, and so on. The message is clear - the statistics by themselves mean little. We need to visualize the data to see patterns. 

![Four scatterplots](https://shawnnstewart.github.io/images/Anscombe.png "four scatterplots")

We can explore Anscombe's fabricated datasets ourselves in R. Here is the code that created the above graphics, provided by Dr. Karl Ho as a part of his EPPS 6356 course at UT Dallas.  
```
## Anscombe (1973) Quartet

data(anscombe)  # Load Anscombe's data
View(anscombe) # View the data
summary(anscombe)

## Simple version
plot(anscombe$x1,anscombe$y1)
summary(anscombe)

# Create four model objects
lm1 <- lm(y1 ~ x1, data=anscombe)
summary(lm1)
lm2 <- lm(y2 ~ x2, data=anscombe)
summary(lm2)
lm3 <- lm(y3 ~ x3, data=anscombe)
summary(lm3)
lm4 <- lm(y4 ~ x4, data=anscombe)
summary(lm4)
plot(anscombe$x1,anscombe$y1)
abline(coefficients(lm1))
plot(anscombe$x2,anscombe$y2)
abline(coefficients(lm2))
plot(anscombe$x3,anscombe$y3)
abline(coefficients(lm3))
plot(anscombe$x4,anscombe$y4)
abline(coefficients(lm4))


## Fancy version (per help file)

ff <- y ~ x
mods <- setNames(as.list(1:4), paste0("lm", 1:4))

# Plot using for loop
for(i in 1:4) {
  ff[2:3] <- lapply(paste0(c("y","x"), i), as.name)
  ## or   ff[[2]] <- as.name(paste0("y", i))
  ##      ff[[3]] <- as.name(paste0("x", i))
  mods[[i]] <- lmi <- lm(ff, data = anscombe)
  print(anova(lmi))
}

sapply(mods, coef)  # Note the use of this function
lapply(mods, function(fm) coef(summary(fm)))

# Preparing for the plots
op <- par(mfrow = c(2, 2), mar = 0.1+c(4,4,1,1), oma =  c(0, 0, 2, 0))

# Plot charts using for loop
for(i in 1:4) {
  ff[2:3] <- lapply(paste0(c("y","x"), i), as.name)
  plot(ff, data = anscombe, col = "blue4", pch = 21, bg = "white", cex = 1.2,
       xlim = c(3, 19), ylim = c(3, 13))
  abline(mods[[i]], col = "darkorange2")
}
mtext("Anscombe's 4 Regression data sets", outer = TRUE, cex = 1.5)
par(op)

```
