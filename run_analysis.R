## Runs the planned analyis. See readme.md for detailed analysis plan
run_analysis <-function(outputLarge="tidyAccelerometerDataLarge.txt", 
                        outputAggregate="tidyAccelerometerDataAggregate.txt") {
    library(magrittr); library(plyr); 
    dataLarge <- merge_datasets() %>% extract_measures %>% label_activities %>%
        rename_features
    write.table(dataLarge,outputLarge,row.names=FALSE)
    dataLarge %>% aggregate_repeats %>% write.table(outputAggregate,row.names=FALSE)
}



## This function loads the acceleromoter data from the disk and merges the
## training and testing datasets. 
## Arguments:
##  trainFiles, testFiles:  lists of three named strings with the locations of the
##                          features file with accelerometer data, activities file
##                          activity codes for each row of the features file, and
##                          subjects file with subject codes for each row of the
##                          features file
##  featureDesc:            file location for the list of column names for the 
##                          features file
## Value: data.frame with variables for subject, activity, and all 561 feature types
merge_datasets <- function (trainFiles=list(features="./data/train/X_train.txt",
                                            activities="./data/train/Y_train.txt",
                                            subjects="./data/train/subject_train.txt"),
                            testFiles=list(features="./data/test/X_test.txt",
                                           activities="./data/test/Y_test.txt",
                                           subjects="./data/test/subject_test.txt"),
                            featureDesc="./data/features.txt") {
    featureNames<-as.character(read.table(featureDesc,stringsAsFactors=FALSE)[,2])
    
    # Helper function to simplify loading the two filesets
    load_dataset <- function (fileList) {
        cbind(read.table(fileList$subjects,col.names="subject",stringsAsFactors=FALSE),
              read.table(fileList$activities,col.names="activity",stringsAsFactors=FALSE),
              # able to access to featureNames variable through lexical scoping
              read.table(fileList$features,col.names=featureNames,stringsAsFactors=FALSE)
        )
    }
    
    rbind(load_dataset(trainFiles),
          load_dataset(testFiles))
}

## This function extracts the mean and standard deviation feature measurements from
## a dataset created by merge_datasets
## Arguments:
##  data:       data frame of the format returned by merge_datasets
##  measures:   character vector of strings that will be partially matched
##              to column names in the data frame
## Value:   data frame with non-matching feature columns removed 
##          (subject and activity id coulmns are preserved)
extract_measures <- function (data,measures=c("mean","std")) {
    # build a regular expression to match any of the strings in measures
    # within variable names in data. The word boundary "\\b" keeps mean 
    # from also mathcing meanFreq; measures default makes "mean\\b|std\\b"
    search<-paste(measures,"\\b",sep="",collapse="|")
    data[,c(1:2,grep(search,names(data),))]
}

## Takes a data frame of the form returned by merge_datasets and converts
## the activities variable to a factor with descriptive labels
## Arguments:
##  data:           A data frame of the form returned by merge_datasets
##  activityDesc:   Table data file with two columns, relating activity id (col 1)
##                  to activity label (col 2)
## Value:   Data frame with the activity column reformated as a labeled factor
label_activities <- function (data,activityDesc="./data/activity_labels.txt") {
    activityNames<-read.table(activityDesc,stringsAsFactors=FALSE)
    data$activity <- factor(data$activity,
                            levels=activityNames[,1],
                            labels=activityNames[,2])
    data
}

## Expands abbreviations in variables names to improve tidiness
## Arguments:
##  data:           A data frame of the form returned by merge_datasets
##  updates:        List of length 2 character vectors. The first of each
##                  is the phrase that will be matched via regexp to existing
##                  variable names and the second of each is string that will 
##                  replace each match. 
## Value:   data frame with updated variable names
rename_features <- function (data,updates = list(c("^t","time"),
                                                 c("^f","frequency"),
                                                 c("Gyro","Gyroscope"),
                                                 c("Acc","Accelerometer"),
                                                 c("mean","Mean"),
                                                 c("std","StdDev"),
                                                 c("Mag","MagnitudeEuclidean"),
                                                 c("\\.",""))) {
    
    # Use lexical scoping of the anonymous function in the lapply call
    # to directly modify the data variable in this environment (its parent)
    lapply(updates, function(searchRep)
            names(data) <<- 
               gsub(searchRep[1],searchRep[2],names(data),ignore.case=TRUE)
        )
    data
}

## Finds the average value for each subject-activity combination
## Arguments:
##  data:       data frame of the form returned by merge_datasets
## Value:   New data frame that reduced duplicate subject-activity observations
##          by averaging all repeated observations. 
aggregate_repeats <- function (data) {
    ddply(data,.(subject,activity),numcolwise(mean))
}