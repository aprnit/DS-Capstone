
#-------------------------------------------------------------------------------------------#
#  R file for the Data Science: CYO CAPSTONE (HarvardX - PH125.9x) project for completion   #
#  of Data Science Professional Certificate from HarvardX through EDX                       #
#  Author: Nitin Sinha                                                                      #
#  Date: May 2, 2019                                                                        #
#                                                                                           #
#  This R scirpt does not need to be run, all the code contained here is also in the        #
#  accompanying RMD file. For testing the code and generating the HTML report, please       #
#  run the RMD file instead                                                                 #
#                                                                                           #
#  This R Script has 4 Code Sections:                                                       # 
#       - Section 1:    DATA LOADING - Downloads data from KAGGLE and creates               #
#                       creditcard.csv file in the working directory                        #
#       - Section 2:    DATA EXPLORATION AND ANALYSIS - This section explains the process   # 
#                       and techniques used - data exploration and visualization,           #
#                       to gain any insights into the data                                  #
#       - Section 3:    RESULTS - Uses Machine Learning Model - Random Forest to detect     #
#                       Credit Card Fraud                                                   #
#       - Section 4:    Finally we run the RMD file to generate the HTML report             #
#                                                                                           #
#       NOTE THAT IT TAKES A WHILE TO RUN THIS PROGRAM - Fitting the RandomeForest Model    #
#       TAKES MORE THAN 20 MINS on 16BB, I5 MAC                                             #
#-------------------------------------------------------------------------------------------#

## Using Random Forest to Detect Credit Card Fraud
# Credit Card Fraud Database can be downloaded from KAGGLE, one of the sites suggested by EDX
# https://www.kaggle.com/mlg-ulb/creditcardfraud

# Loading Required Libraries
if (!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if (!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if (!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if (!require(pROC)) install.packages("pROC", repos = "http://cran.us.r-project.org")
if (!require(knitr)) install.packages("knitr", repos = "http://cran.us.r-project.org")
if (!require(randomForest)) install.packages("randomForest", repos = "http://cran.us.r-project.org")
if (!require(grid)) install.packages("grid", repos = "http://cran.us.r-project.org")
if (!require(gridExtra)) install.packages("gridExtra", repos = "http://cran.us.r-project.org")
if (!require(corrplot)) install.packages("corrplot", repos = "http://cran.us.r-project.org")

# Read the Credit Card Transaction file from 2013 for 2 days from a Bank, Loading data takes about 3 mins
#df <- read.csv("creditcard.csv", stringsAsFactors = FALSE)
df <- read.csv("creditcard.csv", colClasses = c("Class" = "factor"))

#str(df)
# There are only three known variables - Time, Amount and Class, Other V1 through V28 are unknown variables

# Glimpse of Data
head(df, 10)

## Other data points
cat("Number of Rows: ", nrow(df))
# Plotting normal and fradulent transactions against amounts charged on the credit card
df %>% ggplot(aes(Time, Amount)) + geom_point() + facet_grid(Class ~ .)
# Nothing stands out, in fact fraudulent trsnsaction values are less than normal credit card transaction values

## Filtering out transactions above 300
df$Class <- as.factor(df$Class)
df %>% filter(Amount < 300) %>% ggplot(aes(Class, Amount)) + geom_violin()
# This tells us something - The amount involved in fraudulent transactions seems more likely to be around 100 than in non - fraudulent transactions

## Plot Correlation
df_minus_class <- df[,-31]
correlations <- cor(df_minus_class, method = "pearson")
corrplot(correlations, number.cex = .9, method = "square", type = "upper", tl.cex = 0.8, tl.col = "black")
# As you can see by this chart there is very little correlation belween variables

# Use 90% for training and 10% for testing
idxs <- sample(nrow(df), size = 0.1 * nrow(df))
train <- df[-idxs,]
test <- df[idxs,]
#y_train <- train$Class
#y_test <- test$Class

## Next we train the model using RandomForest
n <- names(train)
rf.form <- as.formula(paste("Class ~", paste(n[!n %in% "Class"], collapse = " + ")))
set.seed(1)
rf <- randomForest(rf.form, train, ntree = 20, importance = TRUE)

## We can see which variables in the whole set are important
varimp <- data.frame(rf$importance)
vi1 <- ggplot(varimp, aes(x = reorder(rownames(varimp), MeanDecreaseAccuracy), y = MeanDecreaseAccuracy)) +
    geom_bar(stat = "identity", fill = "grey", colour = "black") +
    coord_flip() + theme_bw(base_size = 8) +
    labs(title = "Prediction using RandomForest with 20 trees", subtitle = "Variable importance (MeanDecreaseAccuracy)", x = "Variable", y = "Variable importance (IncNodePurity)")

vi2 <- ggplot(varimp, aes(x = reorder(rownames(varimp), MeanDecreaseGini), y = MeanDecreaseGini)) +
    geom_bar(stat = "identity", fill = "lightblue", colour = "black") +
    coord_flip() + theme_bw(base_size = 8) +
    labs(title = "Prediction using RandomForest with 20 trees", subtitle = "Variable importance (MeanDecreaseGini)", x = "Variable", y = "Variable importance (%IncMSE)")

grid.arrange(vi1, vi2, ncol = 2)

#This could also have been achieved by the following line of code but the chart does not look as pretty
# varImpPlot(rf, type = 2)
#From this Chart we infer that the important Parameters are - v1, v4, v10, v11, v12, v14 and v17
# Therefore in next cycle we can run the Random Tree with 100 trees with formula just using the above varaible
#rf.form = as.formula("Class ~ Time + V1 + V4 + V10 + V11 + V12 + V14 + V17 + Amount")
#rf <- randomForest(rf.form, train, ntree = 100, importance = T)

# Predict how this model does against the test set
test$predicted <- predict(rf, test)

# Confustion Matrix
#conf_matrix <- caret::confusionMatrix(test$predicted, test$Class)
conf_matrix <- caret::confusionMatrix(test$predicted, test$Class)
conf_matrix$overall["Accuracy"]
conf_matrix$byClass["Sensitivity"]
conf_matrix$byClass["Specificity"]
## Accuracy is pretty high and sensitivity nearly 1, so 20 Trees are sufficient for this dataset
# There are methods to explore optimum number of trees for this dataset, but it takes lot of 
# processing power and will require machine more powerful than my laptop


## Plot for Confusion Matrix 
fourfoldplot(conf_matrix$table, color = c("#CC6666", "#99CC99"), conf.level = 0, margin = 1, main = "Confusion Matrix")
cat("Total Number of Records in the Test Set :", nrow(test))
cat("Of these", table(test$Class)["1"], "are marked as Fraud")
cat("Of the", table(test$Class)["1"], "Fraud cases, our model correctly predicts", conf_matrix$table[4], "as Fraud")
cat("Our model does not detect", conf_matrix$table[3], "as Fraud. This is False Negative, but as mentioned before not so harmful")
cat("Our model marks", conf_matrix$table[2], "as Fraud. This is False Positive")
cat("Therefore Percentage of False Positive:", round(conf_matrix$table[2] * 100 / table(test$Class)["1"], 1), "%. Not so bad eh!")


## Lets Plot all the correct and incorrect predictions
corr_incorr <- data.frame(Predicted = test$predicted, True = test$Class) %>%
    mutate(Correct = ifelse(Predicted == True, TRUE, FALSE)) %>%
    mutate(Time = test$Time, Amount = test$Amount)
ggplot(data = corr_incorr, aes(Time, Amount, col=Correct)) + geom_point()





