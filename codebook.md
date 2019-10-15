# Codebook

The raw data for the project is available here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The wearables_summary.txt file contains a data set which combines the 'test' and 'train' data.

From the raw data file 'X_test.txt' the columns relating to mean and standard deviation are selected. This file is then reshaped into a tidy format. 
From the raw data file 'y_test.txt' the activity relating to each observation is appended, the correspondence between the activity code and the description of the activity is taken from the raw data file activity_labels.txt. 
From the raw data file 'subject_test.txt' the subject ID is appended.
This process is repeated with the 'train' data and the results are appended row-wise.

The mean by subject, activity and feature are taken and stored in the file wearables_summary.txt.

This file has four columns:
subject_id which uniquely identifies the subject.
activity_label which uniquely identifies the activity.
feature which uniquely identifies the feature being measured.
mean_measurement shows the mean of the measurement as presented in the raw data (which are normalised and bounded within [-1,1])
