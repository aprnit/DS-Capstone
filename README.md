# DS-Capstone

R and RMD files for the Data Science: CYO CAPSTONE (HarvardX - PH125.9x) project for 
completion of Data Science Professional Certificate from HarvardX through EDX               
Author: Nitin Sinha
Date: May 2, 2019
                                                                                           
The R scirpt does not need to be run, all the code contained in R code is also in the 
accompanying RMD file. For testing the code and generating the HTML report, please 
run the RMD file instead, using the following commands:

``library(rmarkdown)``  
``render("CreditCardFraud.rmd", "pdf_document")``

This R Script, RMD file, PDF and HTML reports have 4 Code Sections:
## Section 1:
INTRODUCTION and DATA LOADING - Introduces the topic and data used for this project

## Section 2:
DATA EXPLORATION AND ANALYSIS - This section explains the process and techniques used 
- data exploration and visualization, to gain any insights into the data

## Section 3:
RESULTS - Uses Machine Learning Model - Random Forest to detect Credit Card Fraud

## Section 4:
Finally we run the RMD file to generate the HTML report

NOTE THAT IT TAKES A WHILE TO RUN THIS PROGRAM - Fitting the RandomeForest Model
TAKES MORE THAN 20 MINS on 16BB, I5 MAC  
#-----------------------------------------------------------------------------------------------------------------------#

Credit Card Fraud Database can be downloaded from KAGGLE, one of the sites suggested by EDX
https://www.kaggle.com/mlg-ulb/creditcardfraud
