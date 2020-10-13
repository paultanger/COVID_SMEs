data_dir = '/Users/pault/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/SME_data/'
setwd(data_dir)

# data = read.csv('RECOVR_final_melted_for_R.csv', stringsAsFactors = TRUE)
# this version has caseids which we need to map to unique combinations
# of responses
data = read.csv('RECOVR_caseids_final_melted_for_R.csv', stringsAsFactors = TRUE)


# discard blank
data2 = data[data$value != '',]

# get lookup tables for business sector
# CDI sector
CDI_sector_labels = read.csv('RECOVR_main_job_sector_labels_final.csv')
CDI_sector_labels = CDI_sector_labels[CDI_sector_labels$country == 'CDI', c(1,2,5)]
names(CDI_sector_labels)[names(CDI_sector_labels) == "main_job_sector"] <- "value"

# RWA 
RWA_biz_open_labels = read.csv('RECOVR_biz_still_open_labels_final.csv')
RWA_biz_open_labels = RWA_biz_open_labels[RWA_biz_open_labels$country == 'RWA', c(1,2,5)]
names(RWA_biz_open_labels)[names(RWA_biz_open_labels) == "biz_still_open"] <- "value"

# update these rows

# with data.table
library(data.table)

setDT(data2)[setDT(RWA_biz_open_labels), on = c('country', 'value'), value := i.consolidated_label]
setDT(data2)[setDT(CDI_sector_labels), on = c('country', 'value'), value := i.consolidated_label]

# discard blank
data3 = data2[data2$value != '',]
data3 = droplevels(data3)
levels(data3$value)

# replace other lookup values
labels = read.csv('labels_lookup_final.csv', stringsAsFactors = TRUE)
labels = labels[,c(1,3)]
setDT(data3)[setDT(labels), on = c('value'), value := i.short_value_final]

data3 = data3[data3$value != '',]
data3 = droplevels(data3)
levels(data3$value)
# 
# # filter for biz still open and response starts with yes or no
# # data3 = subset(data2, variable == 'biz_still_open')
# data3 = subset(data2, variable %in% c('biz_still_open', 'main_job_sector'))
# data3 = droplevels(data3)
# levels(data3$variable)
# data4 = data3[startsWith(as.character(data3$value), 'Ye') | startsWith(as.character(data3$value), 'N'),]
# 
# data4 = droplevels(data4)
# levels(data4$value)
# biz_still_open = data4[,c(1,3)]
# 
# # get counts for each level
# test = table(data4)

# get counts for each variable and make wide? too wide?
# well first we need to filter by caseid for answers to separate into sectors
# make this wide for responses to each question for caseids

require(reshape2)
# test2 = dcast(data3, value ~ country + variable)

wide = dcast(data3[,-c(2)], caseid ~ variable)

# only keep if said yes to biz in feb
wide2 = wide[wide$run_biz_feb == 'Yes' | wide$work_fam_biz_feb == 'Yes', ]

# now count answers by country and sector
# we don't need caseid anymore since each row is unique
wide2$country = do.call('rbind', strsplit(as.character(wide2$caseid), '_'))[,2]
wide_biz = wide2[,c(2,3,6,7)]

# country_sect_counts = dcast(wide_biz, ~ country + main_job_sector)

# melt by country and sector and question
country_sect_question_counts  = melt(wide_biz, id.vars=c('country', 'main_job_sector'), na.rm=TRUE)

# drop nas
# country_sect_question_counts = country_sect_question_counts[!country_sect_question_counts$value == '',]
# country_sect_question_counts = country_sect_question_counts[!is.na(country_sect_question_counts$value),]

country_sect_counts = dcast(country_sect_question_counts, country + main_job_sector ~ variable + value)

require(dplyr)
# lapply(data3, count)
country_sect_counts2 = country_sect_question_counts %>% count(country, main_job_sector, variable, value)
write.csv(country_sect_counts2, 'country_sect_counts2.csv', row.names=FALSE)
# test4 = data3 %>% 
#   group_by(country, variable) %>%
#   summarise(no_rows = length(country))

# # load short labels
# labels = read.csv('labels_lookup.csv', stringsAsFactors = TRUE)
# 
# # merge
# merged = merge(biz_still_open, labels, by="value")

# plot this
require(ggplot2)
require(scales)
p1 <- ggplot(merged, aes(short_value)) + geom_bar(na.rm = TRUE) + facet_wrap( ~ country, ncol=1, scales = "free_x")
p1 = p1 + scale_x_discrete(labels = wrap_format(10))
p1 = p1 + ggtitle('Is your business still open?') 
p1 <- p1 +  xlab('response') + ylab('total responses')
p1 = p1 + theme(panel.grid = element_blank(),
                axis.ticks.x = element_blank(),
                # strip.background = element_blank(),
                panel.background = element_blank(),
                plot.title = element_text(hjust = 0.5))
# p1 = p1 + theme(axis.text.x = element_text(angle = 90))
p1
ggsave('biz_still_open_plot_v1.png', width=8.5, height=11, units='in')
