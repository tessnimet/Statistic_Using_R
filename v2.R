1. Merge the Datasets
Combine all datasets (GT_2011, GT_2012, GT_2013, GT_2014, GT_2015) into a single dataset.
Load the datasets:

gt_2011 <- read.table(file = file.choose(), header = TRUE, sep = ",")
gt_2012 <- read.table(file = file.choose(), header = TRUE, sep = ",")
gt_2013 <- read.table(file = file.choose(), header = TRUE, sep = ",")
gt_2014 <- read.table(file = file.choose(), header = TRUE, sep = ",")
gt_2015 <- read.table(file = file.choose(), header = TRUE, sep = ",")

Merge them using rbind():

gt_combined <- rbind(gt_2011, gt_2012, gt_2013, gt_2014, gt_2015)


2. Data Understanding
Gain a comprehensive understanding of the merged dataset.

Steps in R:
Inspect the structure:

str(gt_combined)
dim(gt_combined)

Preview the data:

head(gt_combined)
tail(gt_combined)

Summary statistics:

summary(gt_combined)

Check for missing values:

sum(is.na(gt_combined))       # Total missing values
colSums(is.na(gt_combined))   # Missing values per column

3. Data Preparation
Prepare the merged dataset for analysis.

sum(is.na(gt_combined))       # Total missing values
colSums(is.na(gt_combined))   # Missing values per column


#visualizing outliers:

# Boxplot for Air Filter Differential Pressure (AFDP)
boxplot(gt_combined$AFDP, main = "Boxplot of Air Filter Differential Pressure (AFDP)", col = "lightblue")

# Boxplot for Gas Turbine Exhaust Pressure (GTEP)
boxplot(gt_combined$GTEP, main = "Boxplot of Gas Turbine Exhaust Pressure (GTEP)", col = "lightgreen")

# Boxplot for Turbine Inlet Temperature (TIT)
boxplot(gt_combined$TIT, main = "Boxplot of Turbine Inlet Temperature (TIT)", col = "orange")

# Boxplot for Turbine After Temperature (TAT)
boxplot(gt_combined$TAT, main = "Boxplot of Turbine After Temperature (TAT)", col = "pink")

# Boxplot for Turbine Energy Yield (TEY)
boxplot(gt_combined$TEY, main = "Boxplot of Turbine Energy Yield (TEY)", col = "purple")

# Boxplot for Compressor Discharge Pressure (CDP)
boxplot(gt_combined$CDP, main = "Boxplot of Compressor Discharge Pressure (CDP)", col = "yellow")

# Boxplot for Carbon Monoxide (CO)
boxplot(gt_combined$CO, main = "Boxplot of Carbon Monoxide (CO)", col = "cyan")

# Boxplot for Nitrogen Oxides (NOX)
boxplot(gt_combined$NOX, main = "Boxplot of Nitrogen Oxides (NOX)", col = "red")

# Boxplot for Ambient Temperature (AT)
boxplot(gt_combined$AT, main = "Boxplot of Ambient Temperature (AT)", col = "lightblue")

# Boxplot for Ambient Pressure (AP)
boxplot(gt_combined$AP, main = "Boxplot of Ambient Pressure (AP)", col = "lightgreen")

# Boxplot for Ambient Humidity (AH)
boxplot(gt_combined$AH, main = "Boxplot of Ambient Humidity (AH)", col = "orange")


#Scatterplots for Key Relationships
1. Ambient Temperature vs Carbon Monoxide
plot(gt_combined$AT, gt_combined$CO,
     main = "Ambient Temperature vs Carbon Monoxide",
     xlab = "Ambient Temperature (AT)", ylab = "Carbon Monoxide (CO)",
     col = "blue", pch = 19)
2.
plot(gt_combined$AP, gt_combined$CO,
     main = "Ambient Pressure vs Carbon Monoxide",
     xlab = "Ambient Pressure (AP)", ylab = "Carbon Monoxide (CO)",
     col = "green", pch = 19)
  
3.
plot(gt_combined$TIT, gt_combined$CO,
     main = "Turbine Inlet Temperature vs Carbon Monoxide",
     xlab = "Turbine Inlet Temperature (TIT)", ylab = "Carbon Monoxide (CO)",
     col = "red", pch = 19)
4.
plot(gt_combined$TEY, gt_combined$CO,
     main = "Turbine Energy Yield vs Carbon Monoxide",
     xlab = "Turbine Energy Yield (TEY)", ylab = "Carbon Monoxide (CO)",
     col = "purple", pch = 19)
5.
plot(gt_combined$TIT, gt_combined$NOX,
     main = "Turbine Inlet Temperature vs Nitrogen Oxides",
     xlab = "Turbine Inlet Temperature (TIT)", ylab = "Nitrogen Oxides (NOX)",
     col = "orange", pch = 19)

6.
plot(gt_combined$AT, gt_combined$NOX,
     main = "Ambient Temperature vs Nitrogen Oxides",
     xlab = "Ambient Temperature (AT)", ylab = "Nitrogen Oxides (NOX)",
     col = "cyan", pch = 19)



####################################
4. Outlier Detection and Treatment Using KNN
Instead of removing or capping outliers, use the K-Nearest Neighbors (KNN) method for imputation.

Steps:
Install and load the required package:

install.packages("DMwR2")
library(DMwR2)

1. Identify Columns with Outliers
Before applying KNN, identify which columns have outliers using the IQR method or other visualizations.

(DECIDED TO NOT WORK WITH IT #####"Identify outliers in a specific column using IQR
Q1 <- quantile(gt_combined$CO, 0.25)
Q3 <- quantile(gt_combined$CO, 0.75)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

outliers_CO <- gt_combined$CO[gt_combined$CO < lower_bound | gt_combined$CO > upper_bound]
print(outliers_CO)     )###########



Apply KNN for outlier treatment:

proceeding with KNN only for columns with multiple outliers (skipping AT since it has only one outlier/no need to treat it )

# Columns identified with outliers (excluding AT)
columns_with_outliers <- c("AFDP", "GTEP", "TIT", "TAT", "TEY", "CDP", "CO", "NOX", "AH", "AP")

# Apply KNN imputation only to those columns
gt_combined_knn <- gt_combined
gt_combined_knn[columns_with_outliers] <- knnImputation(gt_combined[columns_with_outliers], k = 5)

since we had this error :
Warning message:
In knnImputation(gt_combined[columns_with_outliers], k = 5) :
  No case has missing values. Stopping as there is nothing to do.
>  
 because knn replaces null values with the nearest neighbor, and wevhave no missing values, we decided to Replace outliers with NA so that KNN imputation can replace those values based on the nearest neighbors.

Replace Outliers with NA
Identify Outliers Using the IQR Method:
for each column, replacing the outliers with NA so KNN can handle them.

# List of columns that need to be treated for outliers
columns_with_outliers <- c("AFDP", "GTEP", "TIT", "TAT", "TEY", "CDP", "CO", "NOX", "AH", "AP")

# Loop through each column to identify outliers and replace them with NA
for (col in columns_with_outliers) {
  
  # Calculate Q1 and Q3
  Q1 <- quantile(gt_combined[[col]], 0.25)
  Q3 <- quantile(gt_combined[[col]], 0.75)
  IQR <- Q3 - Q1
  
  # Define lower and upper bounds
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  # Replace outliers with NA
  gt_combined[[col]][gt_combined[[col]] < lower_bound | gt_combined[[col]] > upper_bound] <- NA
}

#(IQR Calculation: We calculate the interquartile range (IQR) for each column to find the bounds for identifying outliers.
Replace Outliers with NA: Any data points that fall outside the calculated range are replaced with NA, so KNN can later impute those values.)#

#. Apply KNN Imputation
After replacing the outliers with NA, apply KNN imputation to replace those NA values with values based on the nearest neighbors.

# Install the DMwR2 package if not already installed
install.packages("DMwR2")
library(DMwR2)

# Apply KNN imputation to the dataset to replace the NAs (outliers) with nearest neighbor values
gt_combined_knn <- gt_combined  # Create a copy to preserve original data

# Apply KNN imputation only to the columns with outliers
gt_combined_knn[columns_with_outliers] <- knnImputation(gt_combined[columns_with_outliers], k = 5)

"(KNN Imputation: We apply KNN imputation to the columns where we replaced outliers with NA. The k = 5 parameter indicates that KNN will use the 5 nearest neighbors to impute the values for the outliers.)"

# Verify the Results
Check the summary statistics and visualize the treated columns to ensure that the outliers have been properly handled by KNN imputation

# Check summary statistics before and after KNN imputation
summary(gt_combined$CO)             # Original dataset
summary(gt_combined_knn$CO)         # After KNN imputation

# Boxplot for the column CO (example) before and after treatment
boxplot(gt_combined$CO, main = "Boxplot of CO - Before KNN", col = "lightblue")
boxplot(gt_combined_knn$CO, main = "Boxplot of CO - After KNN", col = "lightgreen")


 #Save as a CSV File
To save the cleaned dataset (e.g., gt_combined_knn) as a CSV file:

# Save the cleaned dataset to a CSV file
# Save the cleaned dataset as a CSV file to the specified directory
write.csv(gt_combined_knn, "C:/Users/yosrc/OneDrive/Desktop/projet stat/cleaned combined gt/GT_Combined_Cleaned.csv", row.names = FALSE)

file.exists("GT_Combined_Cleaned.csv")
[1] TRUE
///////////////////////////////


 data <- read.table(file = file.choose(), header = TRUE, sep = ",")
> # Normalize the numeric columns (Min-Max scaling)
> normalize <- function(x) {
+   return ((x - min(x)) / (max(x) - min(x)))
+ }
> 
> # Apply normalization to each numeric column
> normalized_data <- as.data.frame(lapply(data, function(x) if(is.numeric(x)) normalize(x) else x))
> 
> # Check the summary of the normalized data
> summary(normalized_data)
 # Check the minimum and maximum values of each column
> mins <- sapply(normalized_data, min)
> maxs <- sapply(normalized_data, max)
> 
> cat("Column Minimums (Should be 0):\n", round(mins, 3), "\n")
Column Minimums (Should be 0):
 0 0 0 0 0 0 0 0 0 0 0 
> cat("Column Maximums (Should be 1):\n", round(maxs, 3), "\n")
Column Maximums (Should be 1):
 1 1 1 1 1 1 1 1 1 1 1 
> write.csv(normalized_data, "Normalized_GT_Cleaned.csv", row.names = FALSE)
> 
# Test skewness and kurtosis for each column in the normalized data
> for (col in colnames(normalized_data)) {
+   skew <- skewness(normalized_data[[col]])  # Skewness
+   kurt <- kurtosis(normalized_data[[col]])  # Kurtosis
+   
+   # Output the results
+   cat("\nFeature:", col, 
+       "\nSkewness:", round(skew, 3),
+       "\nKurtosis:", round(kurt, 3))
+ }

/ analyse:
Normal Features:
A feature can be considered approximately normal if:

Skewness is close to 0.
Kurtosis is close to 3.

normal_vars<- c("NOX","AP","AT")

# Load the normalized dataset
normalized_data <- read.csv("Normalized_GT_Cleaned.csv")

# Variables identified by user as normally distributed
normal_vars <- c("NOX", "AP", "AT")

# Variables identified by user as non-normally distributed
non_normal_vars <- setdiff(names(normalized_data), normal_vars)

# Print results
cat("Normally distributed variables:\n", normal_vars, "\n\n")
cat("Non-normally distributed variables:\n", non_normal_vars, "\n\n"

# Perform variance tests between pairs of normal variables
var.test(normalized_data$NOX, normalized_data$AT)  # Test between NOX and AT
var.test(normalized_data$NOX, normalized_data$AP)  # Test between NOX and AP
var.test(normalized_data$AT, normalized_data$AP)   # Test between AT and AP
 
 
//// t-tes welsh
*Since our variance tests showed significant differences in the variances between your normal variables, you should use Welch's t-test instead of the regular Student’s t-test. Welch’s t-test is more appropriate when the two groups being compared have unequal variances

 # Perform Welch's t-test between NOX and AT
> t_test_nox_at <- t.test(normalized_data$NOX, normalized_data$AT, var.equal = FALSE)
> cat("Welch's t-test between NOX and AT:\n")

# Perform Welch's t-test between NOX and AP
> t_test_nox_ap <- t.test(normalized_data$NOX, normalized_data$AP, var.equal = FALSE)
> cat("\nWelch's t-test between NOX and AP:\n")


> # Perform Welch's t-test between AT and AP
> t_test_at_ap <- t.test(normalized_data$AT, normalized_data$AP, var.equal = FALSE)
> cat("\nWelch's t-test between AT and AP:\n")


///// regression 
# Fit a linear regression model to predict NOX using AT and AP
model <- lm(NOX ~ AT + AP, data = normalized_data)

# View the model summary
summary(model)


 residuals_model <- resid(lm(NOX ~ AT + AP, data = normalized_data))
> hist(residuals_model, main = "Histogram of Residuals", col = "lightblue",
+      xlab = "Residuals", border = "black", breaks = 50)


 summary(resid(model))
     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
-0.586144 -0.102801 -0.009968  0.000000  0.102986  0.680564 
> 
mean resid =0 so there is no perte of data


kruskal.test(AH ~ TIT)
kruskal.test(AFDP ~ TIT)
kruskal.test(GTEP ~ TIT)
kruskal.test(TAT ~ TIT)
kruskal.test(TEY ~ TIT)
kruskal.test(CDP ~ TIT)

kruskal.test(AFDP ~ AH)
kruskal.test(GTEP ~ AH)
kruskal.test(TAT ~ AH)
kruskal.test(TEY ~ AH)
kruskal.test(CDP ~ AH)

kruskal.test(GTEP ~ AFDP)
kruskal.test(TAT ~ AFDP)
kruskal.test(TEY ~ AFDP)
kruskal.test(CDP ~ AFDP)

kruskal.test(TAT ~ GTEP)
kruskal.test(TEY ~ GTEP)
kruskal.test(CDP ~ GTEP)


kruskal.test(TAT ~ TAT)
kruskal.test(TEY ~ TAT)
kruskal.test(CDP ~ TAT)

kruskal.test(TEY ~ TEY)
kruskal.test(CDP ~ TEY)
*************************
cor(NOX, TEY, method = "spearman")
cor.test(NOX, TEY, method = "spearman")

cor(NOX, CDP, method = "spearman")
cor.test(NOX, CDP, method = "spearman")
 
cor(NOX, AH, method = "spearman")
cor.test(NOX, AH, method = "spearman")
**********************************

normalized_data_cleaned <- normalized_data[, !(colnames(normalized_data) %in% c("TEY", "CDP"))]
head(normalized_data_cleaned)


  


