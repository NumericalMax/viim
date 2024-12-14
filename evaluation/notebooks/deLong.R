library(pROC)

#src_data <- read.csv("~/Desktop/viim/notebooks/ROC_analysis.csv")

# Initialize a results data frame
results <- data.frame(
  squint = character(),
  column = character(),
  subject = character(),
  lower = numeric(),
  auc = numeric(),
  upper = numeric(),
  stringsAsFactors = FALSE
)

suppress_squint <- c("True", "False")
aggregations <- c("min", "max", "mean", "std")
subjects <- unique(src_data$subject)
  
for (squint in suppress_squint) {
  df <- src_data[src_data$suppress_squinting == squint, ]
  
  for (aggregation in aggregations) {
    matching_columns <- names(df)[grep(aggregation, names(df))]
    for (col in matching_columns) {
      
      roc_obj <- roc(df[["label_bin"]], df[[col]])
      ci_roc <- ci.auc(roc_obj, method = "delong", boot.n = 2000, conf.level = 0.95)
      
      # ci_roc typically returns a vector of three values: lower CI, AUC, upper CI
      # Append the results to the data frame
      results <- rbind(results, data.frame(
        squint = squint,
        column = col,
        subject = "All",
        lower = ci_roc[1],
        auc = ci_roc[2],
        upper = ci_roc[3],
        stringsAsFactors = FALSE
      ))
      
      for (subject in subjects) {
        
        
        # ci_roc typically returns a vector of three values: lower CI, AUC, upper CI
        # Append the results to the data frame
        results <- tryCatch(
          {
            roc_obj <- roc(df[df$subject == subject, "label_bin"], df[df$subject == subject, col])
            ci_roc <- ci.auc(roc_obj, method = "delong", boot.n = 2000, conf.level = 0.95)
            
            rbind(results, data.frame(
              squint = squint,
              column = col,
              subject = as.character(subject),
              lower = ci_roc[1],
              auc = ci_roc[2],
              upper = ci_roc[3],
              stringsAsFactors = FALSE
            ))
          }, error = function(e) {
            cat("Error at index", subject, ":", e$message, "\n")
            # Return a default value, e.g. NA, so the loop can continue
            rbind(results, data.frame(
              squint = squint,
              column = col,
              subject = as.character(subject),
              lower = 0,
              auc = 0,
              upper = 0,
              stringsAsFactors = FALSE
            ))
          }
        )
      }
    }
  }
}

# After all loops are done, write the results to a CSV file
write.csv(results, "./auc_results.csv", row.names = FALSE)