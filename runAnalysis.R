# tidy data set creation 
# load train /test data set 
library(dplyr)
# load dplyr package 

# read train data 
train_data=read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_sub=read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train_label=read.table("./data/UCI HAR Dataset/train/y_train.txt")

# read test data 
test_data=read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_sub=read.table("./data/UCI HAR Dataset/test/subject_test.txt")
test_label=read.table("./data/UCI HAR Dataset/test/y_test.txt")

# merge data 

merge_data <- bind_rows(train_data,test_data)
merge_sub  <- bind_rows(train_sub,test_sub)
merge_label <-bind_rows(train_label,test_label)

# load feature names 
feature_names <- read.table("./data/UCI HAR Dataset/features.txt")
# load ativity names 
actvity_names <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# change label names accroding to activity
merge_label[]<- lapply(merge_label, function(x) actvity_names$V2[match(x,actvity_names$V1)])
# rename column names to feature names
colnames(merge_data) <- feature_names$V2

# this is merged data with all descriptive labels 
merge_data_descrptive <- cbind(merge_data,"subject"=merge_sub$V1,"activity"=merge_label$V1)

# select M/mean and std labels from the whole data 
mean_contain_data <- merge_data_descrptive[,grep("[M,m]ean",colnames(merge_data_descrptive))]
std_contain_data <- merge_data_descrptive[,grep("std",colnames(merge_data_descrptive))]

mean_std_contain_data_act_sub <-bind_cols(mean_contain_data,std_contain_data,"activity"=merge_label$V1,"subject"=merge_sub$V1)

# compute avergae of each varibale for each activity and subject 
by_activity_subject <- mean_std_contain_data_act_sub %>%
  group_by(activity,subject) %>% 
  summarise_all(funs(mean))

write.table(by_activity_subject,file='./data/tidy_data/average_activity_subject.txt',row.names = FALSE)
