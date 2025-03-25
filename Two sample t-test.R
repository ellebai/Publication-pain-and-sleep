setwd("E:\\AMU\\pain\\results")

library(foreign)
data<-read.spss("E:\\AMU\\pain\\results\\sig_plv.sav",to.data.frame = T)

data$group <- as.factor(data$group)

# detect the group difference of sleep metrics and PSG traits by two sample t-test,47
# 7:20 include sleep structure, 21:28 include character of spindles, 60:84 include 25 most probable two-step transition 
subset_data <- data[,c(7:20,21:28,60:84) ] 
p_values <- apply(subset_data, 2, function(x) {
  model <- lm(x ~ data$group + data$age + data$sex, data = data)
  anova(model)["data$group", "Pr(>F)"]  
})

p_values_df <- data.frame(variable = colnames(subset_data), p_value = p_values)

#detect the group difference of ALFF by two sample t-test
subset_data <- data[,c(39) ]

p_values <- apply(subset_data, 2, function(x) {
  model <- lm(x ~ data$group + data$age + data$sex+data$FD, data = data)
  anova(model)["data$group", "Pr(>F)"]  
})

p_values_df_alff <- data.frame(variable = colnames(subset_data), p_value = p_values)

combined_p_values_df <- rbind(p_values_df, p_values_df_alff)

write.csv(p_values_df, "p_t-test_covariates.csv", row.names = FALSE)



