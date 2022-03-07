### Peer-graded Assignment: Getting and Cleaning Data Course Project
### Objective: Collect, work with, and clean the given dataset


### Data Download Url
downloadURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

### Setup
library(plyr)
library(data.table)
library(dplyr)

### Step 0: Acquire and Prep data 
# Download data zip file if not already downloaded
if (!file.exists("UCIdata.zip")){
  download.file(downloadURL, "UCIdata.zip", method="curl")
}

# Unzip Data file if not aleady done
if (!dir.exists("UCI HAR Dataset")){
  unzip("UCIdata.zip", list=TRUE)
}


# Read data into data tables
#Train Dataset
trainSub <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
trainX <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
trainY <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = FALSE)

#Test Dataset
testSub <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
testX <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
testY <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = FALSE)

#Labels and other
actLabel <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
colnames(actLabel) <- c("actID", "actLabel")


### Step 1: Merges the training and the test sets to create one data set.
allActivity <- rbind(
  cbind(trainSub, trainX, trainY),
  cbind(testSub, testX, testY)
)
colnames(allActivity) <- c("subject", features[, 2], "activities")


### Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
columnsOfInterst <- grepl("subject|activities|mean|std", colnames(allActivity))
allActivity <- allActivity[, columnsOfInterst]


### Step 3: Uses descriptive activity names to name the activities in the data set
allActivity$activities <- factor(allActivity$activities, levels = actLabel[, 1], 
                               labels = actLabel[, 2])


### Step 4: Appropriately labels the data set with descriptive variable names.
allActivityCols <- colnames(allActivity)
allActivityCols <- gsub("[\\(\\)-]", "", allActivityCols)
allActivityCols <- gsub("^f", "frequency", allActivityCols)
allActivityCols <- gsub("^t", "time", allActivityCols)
allActivityCols <- gsub("Acc", "Accelerometer", allActivityCols)
allActivityCols <- gsub("Mag", "Magnitude", allActivityCols)
allActivityCols <- gsub("Gyro", "Gyroscope", allActivityCols)
colnames(allActivity) <- allActivityCols


### Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Final.dt <- data.table(allActivity)
TidyData <- Final.dt[, lapply(.SD, mean), by = 'subject,activities']
write.table(TidyData, file = "tidydata.txt", row.names = FALSE)
