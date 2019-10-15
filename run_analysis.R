#-----------------------------------------------------
#--- Wearables -- Week 4 exercise for Johns Hopkins R course
#-----------------------------------------------------
#
#
#--- Call libraries
library(tidyverse)
#--- Download and unzip raw data from web address
temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
unzip(temp)
#--- Define base directory for work
base_dir <- "/home/steven/Coursera/JHDS/Data/Week4/"
setwd(base_dir)

#--- Read data from top level in directory structure and add descriptive column names
# Activity labels
setwd("UCI HAR Dataset")
activity_labels <- read_delim("activity_labels.txt"," ",col_names=F)
colnames(activity_labels) <- c("activity_code","activity_label")

# Features
features <- read_delim("features.txt"," ",col_names=F)
colnames(features) <- c("feature_label","feature_name")

# Add flag to identify mean and standard deviation results
features <- add_column(features,mean_or_std=str_detect(features$feature_name,"mean\\(")|str_detect(features$feature_name,"std\\("))
select_features <- filter(features,mean_or_std)$feature_name

#--- Read data associated with 'test' observation set
setwd("test")
# Data linking each observation to a subject (that is, a participant)
subject_test <- read_delim("subject_test.txt"," ",col_names=F)
colnames(subject_test) <- "subject_id"
num_test_obvs <- length(subject_test$subject_id)
# Add column to index each observation
subject_test <- add_column(subject_test,observation_id=1:num_test_obvs)

# Data linking each observation to a set of measurements
X_test <- read_delim("X_test.txt"," ",col_names=F,trim_ws=T)
colnames(X_test) <- features$feature_name
# Add column to index each observation
X_test <- add_column(X_test,observation_id=1:num_test_obvs)

# Data linking each observation to an activity
y_test <- read_delim("y_test.txt"," ",col_names=F)
colnames(y_test) <- "activity_code"
y_test <- add_column(y_test,observation_id=1:num_test_obvs)


#--- Read data associated with 'train' observation set
setwd(file.path(base_dir,"UCI HAR Dataset/train"))
# Data linking each observation to a subject (that is, a participant)
subject_train <- read_delim("subject_train.txt"," ",col_names=F)
colnames(subject_train) <- "subject_id"
num_train_obvs <- length(subject_train$subject_id)
# Add column to index each observation (continue counting after the test data index)
train_obvs_id <- (num_test_obvs+1):(num_test_obvs+num_train_obvs)
subject_train <- add_column(subject_train,observation_id=train_obvs_id)


# Data linking each observation to a set of measurements
X_train <- read_delim("X_train.txt"," ",col_names=F,trim_ws=T)
colnames(X_train) <- features$feature_name
# Add column to index each observation
X_train <- add_column(X_train,observation_id=train_obvs_id)

# Data linking each observation to an activity
y_train <- read_delim("y_train.txt"," ",col_names=F)
colnames(y_train) <- "activity_code"
y_train <- add_column(y_train,observation_id=train_obvs_id)

#--- Select mean and standard deviation results and convert to 'long' format
X_test_select <- select(X_test,observation_id,select_features)

X_test_select <- gather(X_test_select,key=feature,
                     value=measurement,
                        select_features)

X_train_select <- select(X_train,observation_id,select_features)

X_train_select <- gather(X_train_select,key=feature,
                     value=measurement,
                        select_features)

#--- Merge activity label and subject ID to each observation
y_test <- select(left_join(
        x=y_test,y=activity_labels,by="activity_code"),-activity_code)

test_tidy <- left_join(x=X_test_select,y=y_test,by="observation_id")
test_tidy <- left_join(x=test_tidy,y=subject_test,by="observation_id")

y_train <- select(left_join(
        x=y_train,y=activity_labels,by="activity_code"),-activity_code)

train_tidy <- left_join(x=X_train_select,y=y_train,by="observation_id")
train_tidy <- left_join(x=train_tidy,y=subject_train,by="observation_id")

#--- Merge 'test' and 'train' data sets; reorder columns for ease

data_tidy <- bind_rows(test_tidy,train_tidy)
data_tidy <- select(data_tidy,observation_id,subject_id,activity_label,feature,measurement)

#--- Generate mean of each measurement grouped by subject, activity and feature
data_grouped <- group_by(data_tidy,subject_id,activity_label,feature)

data_summary <- summarise(data_grouped,mean_measurement=mean(measurement))

setwd(base_dir)

#--- Write output
write.table(data_summary,"wearables_summary.txt",row.name=FALSE)
