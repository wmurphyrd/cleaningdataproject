# cleaningdataproject

Course project for Coursera/Johns Hopkins Getting and Cleaning Data class

The run_analysis function this repo performs a planned data processing script. 
This script uses accelerometer data collected from subjects performing a variety of
actions with a smart phone that is hosted by the [UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). This script assumes the data is already download and extracted from the zip file (with directory structure) in a folder within the working directory named "data". The processing is performed in 5 steps described below

## 1. Load and Merge Data Sets

The raw data has been split randomly into two data sets to train algorithms and then test them, but we want them recombined for this analysis. Within each split data set, the signal data, subject identifier, and activity identifier exist in three seprate files that need to be recombined for this analysis. 

* The three files are linked by row number, and all have complete data in the correct order. They are easily joined by column-binding after being read from file. 
* The two data sets have identical columns also in matching order. They are easily row-bound to create a single, large data set
* The columns "subject" and "activity" are id codes to describe each observation (row), and the remaining columns are pre-processed signal data

## 2. Exctract desired variables

Of the 561 signals provided, only the mean and standard deviation signals are desired for this data set. Regular expression search of the variables names is used to find those specified as mean or std, and standard subsetting is used to drop the unnecessary columns. The signal type meanFreq is an advanced processing result and is not included. 

## 3. Add descriptive activity names

The id codes for activity types are translated into their descriptive names using the code file provided with the raw data. The activity data is transformed to a factor type for fast processing, and the factor levels are labelled appropriately. Care is taken to avoid mismatching the ids, so the order of the rows in the activity name file is unimportant

## 4. Add descriptive variable names

Abbreviations contained in the orignal signal variable names are expanded and symbols/artifacts in the names are removed. The is accomplished via regular expression substitution.

At this point the data fully processed and a copy is saved to "tidyAccelerometerDataLarge.txt" in a space separated table with headers. This data set contrains 10,299 observations of 66 signals, and each observation is labeled with subject number and activity type. 

## 5. Aggregate means values by subject and activity

The data set contains many repeat observations for each subject and each activity. In this step, the repeats are aggregated and replaced with the average of the individual values. This is accomplished with the plyr package using ddplyr to hande the split-apply-combine process and numcolwise to apply the aggregation function to each signal. 

The average aggregation is appleed to both the mean and standard devation signal types that are included, creating grand means and mean standard deviations. This data is output to the file "tidy AccelerometerDataAggregate.txt" and contains 180 observations for 66 signals. Each observation is labeled with subject number and activity type. 