data_dir = '/Users/pault/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/SME_data/'
setwd(data_dir)

data = read.csv('RECOVR_final_melted_for_R.csv', stringsAsFactors = TRUE)

# discard blank
data2 = data[data$value != '',]

# filter for biz still open and response starts with yes or no
data3 = subset(data2, variable == 'biz_still_open')
data4 = data3[startsWith(as.character(data3$value), 'Ye') | startsWith(as.character(data3$value), 'N'),]

data4 = droplevels(data4)
levels(data4$value)
biz_still_open = data4[,c(1,3)]

# get counts for each level
test = table(data4)

require(reshape2)
test2 = dcast(data4, country ~ value)

require(dplyr)
lapply(data4, count)
data4 %>% count(country, variable, value)

data4 %>% 
  group_by(country) %>%
  summarise(no_rows = length(country))

# load short labels
labels = read.csv('labels_lookup.csv', stringsAsFactors = TRUE)

# merge
merged = merge(biz_still_open, labels, by="value")

# plot this
require(ggplot2)
require(scales)
p1 <- ggplot(merged, aes(short_value)) + geom_bar(na.rm = TRUE) + facet_wrap( ~ country, ncol=1, scales = "free_x")
p1 = p1 + scale_x_discrete(labels = wrap_format(10))
p1 = p1 + ggtitle('Is your business still open?') 
p1 = p1 + theme(plot.title = element_text(hjust = 0.5))
# p1 = p1 + theme(axis.text.x = element_text(angle = 90))
p1
ggsave('biz_still_open_plot_v1.png', width=8.5, height=11, units='in')
