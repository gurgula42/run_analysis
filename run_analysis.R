
## 1. Merge the training and the test sets to create one data set.
## set working directory
setwd("./coursera-r/Getting and cleaning data")

## read data into R
X_test <- read.table("./UCI HAR dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR dataset/test/subject_test.txt")

X_train <- read.table("./UCI HAR dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR dataset/train/subject_train.txt")

features <- read.table("./UCI HAR dataset/features.txt")
activity_labels <- read.table("./UCI HAR dataset/activity_labels.txt")

## opening dplyr package and read data into dbl_df for the dplyr package
library(dplyr)

tbl_df(X_test)->X_test
tbl_df(y_test)->y_test
tbl_df(subject_test)->subject_test

tbl_df(X_train)->X_train
tbl_df(y_train)->y_train
tbl_df(subject_train)->subject_train

## setting column names
colnames(subject_train) <- c("subject")
colnames(subject_test) <- c("subject")

colnames(y_test) <- c("activity")
colnames(y_train) <- c("activity")

## merging train and test data sets into two big tables
cbind(y_train, X_train)->y_X_train
cbind(subject_train, y_X_train)->merged_train

cbind(y_test, X_test)->y_X_test
cbind(subject_test, y_X_test)->merged_test

merged_test$set<-c("test")
merged_train$set<-c("train")


## merge test and train tables

merged_all<-rbind(merged_train, merged_test)

## 2. filter features to find columns with measurements on the mean and standard deviation 
## for each measurement

filter(features, grepl('mean', V2))->filtered_features_mean
filter(features, grepl('std', V2))->filtered_features_std

filtered_features<-rbind(filtered_features_mean, filtered_features_std)

library(dplyr)
tbl_df(merged_all)->mergedd_all

## Extract only the measurements on the mean and standard deviation for each measurement
selected_data <- select(merged_all, subject, activity, (filtered_features$V1+2))


## 3. descriptive activity names to name the activities in the data set

colnames(activity_labels) <- c("activity_nr", "activity")
selected_data$activity<-activity_labels$activity[selected_data$activity] 


## 4. Appropriately label the data set with descriptive variable names

paste("",filtered_features$V2,sep="")->filtered_columnames
colnames(selected_data)<-c("subject", "activity", filtered_columnames)

gsub("-", "", colnames(selected_data))->colnames(selected_data)  # removes "-" form column names
gsub("\\(\\)", "", colnames(selected_data))->colnames(selected_data)  # removes "()" form column names
gsub("mean", "Mean", colnames(selected_data))->colnames(selected_data) # overwrites mean to Mean in column names
gsub("std", "Std", colnames(selected_data))->colnames(selected_data) # overwrites std to Std 


## 5. From the data set in step 4, creates a second, independent tidy data set with the average
##    of each variable for each activity and each subject.

selected_data %>% group_by(activity, subject) %>% summarise_each(funs(mean))->sum_all


## each row is an observation, each column is a variable, 
## and the table contains a single observational unit. Thus, the data is tidy.


## writes the data into txt file for submission

write.table(sum_all, file="./sum_all.txt", row.name=FALSE)