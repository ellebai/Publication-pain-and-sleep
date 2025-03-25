setwd("H:\\results")

library(foreign)
library(ppcor)
library(writexl)

# compute the correlation between phase locking value in N2, N3, REM stages and pain scores and sleep strictures
data<-read.spss("sig_plv.sav",to.data.frame = TRUE)

residuals_1_to_48 <- apply(data[, c(13:30)], 2, function(x) {
  valid_cases <- complete.cases(x, data[, c(65:67,69)])
  lm_res <- lm(x[valid_cases] ~ data[valid_cases, 65] + data[valid_cases, 66] + data[valid_cases, 67])
  residual_values <- residuals(lm_res)
  full_residual_values <- rep(NA, 59)
  full_residual_values[valid_cases] <- residual_values
  return(full_residual_values)
})

residuals_50_to_64 <- apply(data[, c(158:160)], 2, function(x) {
  valid_cases <- complete.cases(x, data[, 65:67]) 
  lm_res <- lm(x[valid_cases] ~ data[valid_cases, 65] + data[valid_cases, 66] + data[valid_cases, 67])  # 仅对有效行进行回归
  residual_values <- residuals(lm_res)
  full_residual_values <- rep(NA, 59)
  full_residual_values[valid_cases] <- residual_values
  return(full_residual_values)
})

partial_corr_results <- cor(residuals_1_to_48, residuals_50_to_64, use = "pairwise.complete.obs")

p_value_matrix <- matrix(NA, nrow = ncol(residuals_1_to_48), ncol = ncol(residuals_50_to_64))

for(i in 1:ncol(residuals_1_to_48)) {
  for(j in 1:ncol(residuals_50_to_64)) {
    test_result <- cor.test(residuals_1_to_48[, i], residuals_50_to_64[, j])
    p_value_matrix[i, j] <- test_result$p.value
  }
}

p<-data.frame(p_value_matrix)
cor<-data.frame((partial_corr_results))
write_xlsx(p,"p_aftermean_plv_tp_fc.xlsx")
write_xlsx(cor,"cor_aftermean_plv_tp_fc.xlsx")



  
  
