data_dir = '/Users/pault/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/SME_data/from_Anna/'
setwd(data_dir)
data = read.csv('long_rfs_pt.csv', stringsAsFactors = TRUE)

new_version = read.csv('long_rfs_pt_new.csv', stringsAsFactors = TRUE)
# check new version results?
data = new_version
# check how many rows have blank questions
blank = data[data$question == '',]
# seems like alot
nrow(blank) / nrow(data)
# other data is here:
other_data_dir = '/Users/pault/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/SME_data/'
setwd(other_data_dir)
# get smaller sample to explore
# sample_size = 100000
# data_samp = data[sample(nrow(data), sample_size), ]

# make list of questions that assess household biz
questions = levels(data$question)
# save to filter
# write.csv(questions, 'new_questions.csv')
# load filtered questions
biz_questions = read.csv('fam_biz_questions_startswith.csv', stringsAsFactors = TRUE)
biz_questions_list = levels(biz_questions$biz_questions)

# filter based on starts with
# setwd(data_dir)
# data = read.csv('long_rfs_pt.csv', stringsAsFactors = FALSE)
# swap back to characters to match
# data_samp$question = sapply(data_samp$question, as.character)
# blank1 = data_samp[data_samp$question1 == '',]

data$question = sapply(data$question, as.character)
blank2 = data[data$question == '',]
nrow(blank2)

# startsWith(data_samp$question, biz_questions_list)
# bool = startsWith(data_samp$question, biz_questions_list)
test = data_samp[startsWith(data_samp$question, biz_questions_list),]
data_filtered = data[startsWith(data$question, biz_questions_list),]
setwd(other_data_dir)
write.csv(data_filtered, 'data_filtered.csv')

# some of these questions seem to not exist in the data?
data[startsWith(data$question, 'Compared to before'),]

# there is an issue with commas, do this again
biz_questions = read.csv('fam_biz_questions_startswith_no_commas.csv', stringsAsFactors = TRUE)
biz_questions_list = levels(biz_questions$biz_questions)
data_filtered2 = data[startsWith(data$question, biz_questions_list),]
write.csv(data_filtered2, 'data_filtered2.csv')

# there isn't that much data here
nrow(data_filtered2)

# even less have an answer..
data_filtered2_answered = data_filtered2[data_filtered2$value != '',]
write.csv(data_filtered2_answered, 'data_filtered2_answered.csv')

# filter hhid which answered yes to family businesses non farm
hhids = read.csv('unique_hhid_yes_fam_biz.csv')
hhids_list = hhids$hhid

data_filtered2_answered$hhid = sapply(data_filtered2_answered$hhid, as.character)

data_filtered3 = data_filtered2_answered[data_filtered2_answered$hhid %in% hhids_list,]
write.csv(data_filtered3, 'data_filtered3.csv')

# Is the non-farm family business still operational?

# 