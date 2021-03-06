#############################################################################
# COMM 581 - Assignment 06 - Multiple Linear Regression with 
#                            Categorical Variables
# Instructor: Martha Essak
# Gurpal Bisra
# Student #: 69295061
# Due date: Thursday Oct. 20, 2016 (11pm)
#############################################################################

# Background: You are analyzing data from a company, Spectra Technologies (science or engineering*), to determine if they are giving equal pay to men and women after controlling statistically for their level of experience. If there is a difference in salary between men and women, the company needs to know how much of a difference there is, and if this difference changes depending on level of experience (if there is an interaction between gender and experience).

# All graphs should be created using R, and all graphs discussed in your assignment should be included with your submission. You can use sum of squares and standard errors from the R output. Show calculations for test statistics, confidence intervals and measures of goodness of fit based on sums of squares.

# You will be presenting this assignment as a report to the company, with your recommendations.

mydata <- read.csv("Salary_experience_gender_data.csv", header=TRUE)
# import data from csv, and declaring header row at top

str(mydata)
    # 'data.frame':	48 obs. of  3 variables:
    # $ experience: int  0 0 1 0 0 0 2 1 2 2 ...
    # $ gender    : Factor w/ 2 levels "female","male": 1 1 1 1 1 1 1 1 1 1 ...
    # $ salary    : int  28300 30400 28950 30850 28700 31550 30450 30450 28500...

#############################################################################
# Summary Statistics (Present these Data in One or More Tables)
#############################################################################

### Question 1 --------------------------------------------------------------
# What is the range of values for salary and experience? What is the range for these variables for men and women? Are the ranges different, and what could account for this difference?

summary(mydata)
    # Range of Experience = [0, 35] years
    # Range of Salary = [28300, 45000] years

table(mydata$gender)
    # female   male 
    # 26       22 

# separate the categories into separate datasets
mydata.m <- subset(mydata, mydata$gender == "male")
mydata.f <- subset(mydata, mydata$gender == "female")

summary(mydata.m)
    # Range of Experience = [1, 35] years
    # Range of Salary = [34550, 45000] years

summary(mydata.f)
    # Range of Experience = [0, 29] years
    # Range of Salary = [28300, 38200] years


### Question 2 --------------------------------------------------------------
# What is the mean value for salary and experience? What is the mean for these variables for men and women? Are the means higher for men or women? What could account for this difference?

summary(mydata)
    # Mean oExperience = 12.75 years
    # Mean Salary = $35,564 years

summary(mydata.m)
    # Mean oExperience = 18.95 years
    # Mean Salary = $39,659 years

summary(mydata.f)
    # Mean oExperience = 7.50 years
    # Mean Salary = $32,098 years


### Question 3 --------------------------------------------------------------
# Graph salary vs. experience, with two different plotting characters, one for men and one for women (remember to explain your plotting characters in the caption or as a legend). Do you think the relationship between salary and experience is linear after including gender as a variable? 

# Scatterplot of Salary vs Experience for males only
# plot(salary ~ experience, data=mydata.m, pch=1, ylim=c(0, 46000))

# Scatterplot of Salary vs Experience for females only
# plot(salary ~ experience, data=mydata.f, pch=1, ylim=c(0, 46000))

# Scatterplot of Salary vs. Experience with different categories (i.e. male and female genders) as different plotting characters
plot(salary ~ experience, data=mydata, col = "blue", pch=c(1, 16)[as.numeric(mydata$gender)], ylim=c(20000, 50000), main = "Salary as Function of Experience", xlab="Experience (years)", ylab="Salary (Dollars per Year)")
     
legend("bottomright", title=expression(bold("Gender")), c("Male","Female"), pch=c(16, 1), col = "blue", cex=1.0, title.adj=0.5)
    # males are black circles because plotting character assigns according to         alphabet

abline(lm(salary ~ experience, data=mydata.m), lty=2) 
    # gives regression line for the male data only, and makes the line dashed

abline(lm(salary ~ experience, data=mydata.f)) 
    # gives regression line for the female data only, and makes the line solid


### Question 4 --------------------------------------------------------------
# Describe your qualitative observations about the relationship between these variables from the graph. Remember to discuss these in the Discussion section.


#############################################################################
# Developing a Model
#############################################################################

### Question 5 --------------------------------------------------------------
# Write the model statement for the (full) interaction model including the interaction between gender and experience. Show the indicator variable for gender. How is the indicator variable coded for men and women? 

# yi= B0 + B1*x1i + B2*x2i+ B3*x1i*x2i+ ??i

# Category	x1
# male	    1
# female	0

# where:
    # yi= Salary [$ per year]
    # B0= Continuous variable's (i.e. experience) intercept term [$]
    # B1= Categorical variable's (i.e. gender) intercept adjustment term
    # x1i= Dummy variable for categorical variable (i.e. indicator term)
    # B2= Continuous variable's slope term
    # x2i= Continuous variable's term
    # ??i= Errors term
    # B3*x1i*x2i= Interaction term


### Question 6 --------------------------------------------------------------
# Fit this model using R. Assess the assumptions of linearity (salary vs. experience graph, residual plot), equal variance (residual plot) and normality of errors (histogram, normality plot, normality tests). State any concerns you have and their consequences.  

# fit a multiple linear regression model with categorical variables
z.full <- lm(salary ~ experience + gender + experience*gender, data=mydata)
    # New dataset --> experience, gender, experience*gender

# Check if relationship is linear
    # Compute residuals of object z.full
resid1 <- resid(z.full)
    # Calculate predicted y_hat values
predict1 <- predict(z.full)

# Residual plot for model
plot(resid1 ~ predict1, pch=16, col = "blue", main = "Residuals of Full Interaction Model", xlab="Salary (Dollars per Year)", ylab="Errors of Residuals of Salary (Dollars per Year)")

# Add line Residuals = 0
abline(0, 0, lty=2)

# Assess assumptions of linearity and equal variance

# Look at the histogram to see whether the residuals are normally distributed
hist(resid1, breaks = seq(-5000, 6000, by=1200), main = "Histogram of Predicted Full Interaction Model", xlab="Errors of Residuals of Salary (Dollars per Year)", ylab="Frequency")

# Q-Q Plot
qqnorm(resid1)
qqline(resid1, main = "Normal Q-Q plot of residuals", col = "red")

# Normality testing with alpha = 0.05
library(nortest)
shapiro.test(resid1)
ad.test(resid1)
cvm.test(resid1)
lillie.test(resid1)

# Plot Salaries vs. y_hat (i.e. predicted salries)
mydata$predict.full <- predict(z.full)
mydata$resid.full <- resid(z.full)
plot(salary ~ predict.full, data = mydata, pch = 16, col = "blue", main = "Salary Values are Similar to Predicted Values", xlab="Predicted Salary (Dollars per Year)", ylab="Salary (Dollars per Year)")

# Fit a linear line of slope 1 to see how well the predicted salaries match the observed salaries
abline(0,1,lty=2, col = "red")


### Question 7 --------------------------------------------------------------
# Note: The data was collected at one point in time, from the single location for the company, so you will not need to investigate if the assumption of independence of errors has been met. Experience was self-reported, so there is no reason to think that there is error associated with it, and salary was obtained from the company records.

### Question 8 --------------------------------------------------------------
# Write the ANOVA table for this model using Type III SS and showing df and SS. See how to do this based on the class example. Sources of variation should be model, error and total. 

# way to see type III SSE
options(contrasts=c("contr.helmert", "contr.poly"))
drop1(z.full, .~., test="F")

mydata$yhat <- mydata$predict.full

SSE <- sum((mydata$salary - mydata$yhat)^2)
SSE
SSR <- sum((mean(mydata$salary) - mydata$yhat)^2)
SSR
SSY <- sum((mydata$salary - mean(mydata$salary))^2)
SSY

### Question 9 --------------------------------------------------------------
# Test the significance of the regression, showing the calculation of the F statistic based on sum of squares. 

summary(z.full)

# Find the F critical value for numerator degrees of freedom = 3, denominator df = 44, alpha = 0.05
qf(0.95, 3, 44) 
    # Fcritical = 2.816466


### Question 10 --------------------------------------------------------------
# Test the significance of the variable gender, using a partial F-test. Remember that gender requires two variables in the model, so you need to fit a model that does not have gender, then compare the two models. Show all steps in your calculation of the partial F-statistic. What does the result of this test mean for the model? Interpret what this result means in terms of the overall purpose of this study. 

z.experience.only <- lm(salary ~ experience, data=mydata) 
    # remove experience, which removes its interactions and the main effect

anova(z.full, z.experience.only)
    # Continuous variable is signifianct

# Find the F critical value for numerator degrees of freedom = 2, denominator df = 44, alpha = 0.05
qf(0.95, 2, 44) 
    # Fcritical = 3.209278

anova(z.experience.only)

summary(z.experience.only)


### Question 11 --------------------------------------------------------------
# Test the significance of the variable experience, using a partial F-test. You will need to fit a model that does not have experience, then compare the full model to this model. What does the result of this test mean for the model? Interpret what this result means in terms of the overall purpose of this study. 

z.gender.only <- lm(salary ~ gender, data=mydata) 
# remove gender, which removes its interactions and the main effect

anova(z.full, z.gender.only)
# Continuous variable is signifianct

# Find the F critical value for numerator degrees of freedom = 2, denominator df = 44, alpha = 0.05
qf(0.95, 2, 44) 
    # Fcritical = 3.209278

anova(z.full)

summary(z.gender.only)


#############################################################################
# Question 12 ---------------------------------------------------------------
# Option A: gender and experience are both required in the model
# (MLR with categorical variable model)

### a) Fit a new model that has the same slopes for men and women. Assess the assumptions of linearity, equal variance and normality.

# Now model includes experience and gender, but not interaction term
# yi= B0 + B1*x1i + B2*x2i + ??i
z.new <- lm(salary ~ experience + gender, data=mydata)

    # Category	x1
    # male	    1
    # female	0

    # where:
        # yi= Salary [$ per year]
        # B0= Continuous variable's (i.e. experience) intercept term [$]
        # B1= Categorical variable's (i.e. gender) intercept adjustment term
        # x1i= Dummy variable for categorical variable (i.e. indicator term)
        # B2= Continuous variable's slope term
        # x2i= Continuous variable's term
        # ??i= Errors term

# Check if relationship is linear
    # Compute residuals of object z.new
resid2 <- resid(z.new)
    # Calculate predicted y_hat values
predict2 <- predict(z.new)

# Residual plot for model
plot(resid2 ~ predict2, pch=16, col = "blue", main = "Residuals of Non-Interaction Model", xlab="Salary (Dollars per Year)", ylab="Errors of Residuals of Salary (Dollars per Year)")

# Add line Residuals = 0
abline(0, 0, lty=2)

# Assess assumptions of linearity and equal variance

# Look at the histogram to see whether the residuals are normally distributed
hist(resid2, breaks = seq(-5000, 6000, by=1200), main = "Histogram of Predicted Non-Interaction Model", xlab="Errors of Residuals of Salary (Dollars per Year)", ylab="Frequency")

# Q-Q Plot
qqnorm(resid2)
qqline(resid2, main = "Normal Q-Q plot of Residuals", col = "red")

# Normality testing with alpha = 0.05
library(nortest)
shapiro.test(resid2)
ad.test(resid2)
cvm.test(resid2)
lillie.test(resid2)

# Plot Salaries vs. y_hat (i.e. predicted salries)
mydata$predict.new <- predict(z.new)
mydata$resid.new <- resid(z.new)
plot(salary ~ predict.new, data = mydata, pch = 16, col = "blue", main = "Salary Values are Similar to Non-Interaction Predicted Values", xlab="Predicted Salary (Dollars per Year)", ylab="Salary (Dollars per Year)")

# Fit a linear line of slope 1 to see how well the predicted salaries match the observed salaries
abline(0,1,lty=2, col = "red")

### b) Use a partial F-test to determine if the slopes are the same or different. What does the result of this test mean for the model? Interpret what this result means in terms of the overall purpose of this study. 

# Test the signficiance of the regression when compared to z.new
anova(z.full, z.new)
    # Interaction is not significant

# Find the F critical value for numerator degrees of freedom = 1, denominator df = 46, alpha = 0.05
qf(0.95, 1, 46) 
    # Fcritical = 4.061706

# Test the significance of the regression, showing the calculation of the F statistic based on sum of squares. 

summary(z.new)

# Find the F critical value for numerator degrees of freedom = 2, denominator df = 45, alpha = 0.05
qf(0.95, 1, 45) 
    # Fcritical = 4.056612

# Test the signifiance of the categorical varaible gender
anova(z.new, z.experience.only)
    # Categorical variable is signifianct

# Find the F critical value for numerator degrees of freedom = 3, denominator df = 44, alpha = 0.05
qf(0.95, 1, 45) 
    # Fcritical = 4.061706

anova(z.new)

# Test the signifiance of the continuous varaible experience
anova(z.new, z.gender.only)
    # Continuous variable is signifianct

# Find the F critical value for numerator degrees of freedom = 3, denominator df = 44, alpha = 0.05
qf(0.95, 1, 45) 
    # Fcritical = 4.061706


#############################################################################
# Final Model
#############################################################################

### Question 13 --------------------------------------------------------------
# Write the model equation with variable names (including any indicator variables). Write the model with the values of the co-efficients in the equation. What does each of these co-efficients represent?  

summary(z.new)
# yi= B0 + B1*x1i + B2*x2i + ??i
# yi_hat = 32584.11 + (249.07)*(experience_i) + (2354.03)*(gender_i)

    # Category	x1
    # male	    1
    # female	0

    # where:
        # yi= Salary [$ per year]
        # B0= Continuous variable's (i.e. experience) intercept term [$]
        # B1= Categorical variable's (i.e. gender) intercept adjustment term
        # x1i= Dummy variable for categorical variable (i.e. indicator term)
        # B2= Continuous variable's slope term
        # x2i= Continuous variable's term
        # ??i= Errors term


### Question 14 --------------------------------------------------------------
# If you chose option A or C, what is the equation to calculate predicted salary for men? For women? If you chose option B, what is the equation relating salary and experience? 

# Salary_men= 32584.11+ 249.07*(experience)                 [$/year]

# Salary_female= 32584.11 + 2354.03+ 249.07*(experience)    [$/year]


### Question 15 --------------------------------------------------------------
# Calculate the measures of goodness of fit: R2 and root MSE. What represents a good fit for these measures? 

SSE <- sum((mydata$salary - mydata$yhat)^2)
SSE
SSR <- sum((mean(mydata$salary) - mydata$yhat)^2)
SSR
SSY <- sum((mydata$salary - mean(mydata$salary))^2)
SSY

summary(z.new)

# ----------------------------------------------------------------------------

# Scatterplot of Salary vs. Experience with different categories (i.e. male and female genders) as different plotting characters
plot(salary ~ experience, data=mydata, col = "blue", pch=c(1, 16)[as.numeric(mydata$gender)], ylim=c(20000, 50000), main = "Salary as Function of Experience", xlab="Experience (years)", ylab="Salary (Dollars per Year)")

legend("bottomright", title=expression(bold("Gender")), c("Male","Female"), pch=c(16, 1), col = "blue", cex=1.0, title.adj=0.5)
# males are black circles because plotting character assigns according to         alphabet

abline(34938.14, 249.07, lty=2) 
# gives regression line for the male data only, and makes the line dashed

abline(30230.08, 249.07)
# gives regression line for the female data only, and makes the line solid

# ----------------------------------------------------------------------------
# Describe data used, and stats packages used (including version)
citation()