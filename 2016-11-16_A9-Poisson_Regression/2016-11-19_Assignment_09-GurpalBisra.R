###################################
# ASSIGNMENT 9 - POISSON REGRESSION
# Instructor: Martha Essak
# Gurpal Bisra
# Student Number: 69295061 
# Nov. 21, 2016
###################################

# 1. What are your predictions (with explanation) regarding the relationships between explanatory variables and the response variable? (1 mark)

#----------------------------------------------------------------------------------------------

######################
# IMPORT DATA
######################

# 2. Import the data and change program to a factor using the factor command (change the labels to make them more informative).

mydata <- read.csv("awards_data.csv", header=TRUE)

str(mydata)
# > str(mydata)
# 'data.frame':	200 obs. of  4 variables:
# $ id        : int  1 2 3 4 5 6 7 8 9 10 ...
# $ num.awards: int  0 0 0 1 1 0 1 0 0 1 ...
# $ prog      : int  3 3 2 2 2 2 2 2 3 1 ...
# $ math      : int  40 33 48 41 43 46 59 52 52 49 ...

mydata$program <- as.factor(mydata$prog)
str(mydata)
# 'data.frame':	200 obs. of  5 variables:
# $ id        : int  1 2 3 4 5 6 7 8 9 10 ...
# $ num.awards: int  0 0 0 1 1 0 1 0 0 1 ...
# $ prog      : int  3 3 2 2 2 2 2 2 3 1 ...
# $ math      : int  40 33 48 41 43 46 59 52 52 49 ...
# $ program   : Factor w/ 3 levels "1","2","3": 3 3 2 2 2 2 2 2 3 1 ... 

#----------------------------------------------------------------------------------------------

# 3. Create a histogram of the responses. Do you think this follows a Poisson distribution? Why or why not? (1 mark)

# response variable
hist(mydata$num.awards, main = "Histogram of Awards Data", xlab="Number of Awards", ylab="Frequency")

# Do you think the data follows a Poisson distribution?

# You could simulate data that follows a Poisson distribution to check.
mean(mydata$num.awards) # 0.63
nrow(mydata) # 200
# have 200 observations

# now, simulate data to see if histogram is Poisson
poisson.sim.data <- rpois(200, 0.63)
hist(poisson.sim.data, breaks=seq(0, 7, by=0.5), ylim=c(0,110), main = "Histogram of Awards Data", xlab="Simulated Number of Awards", ylab="Frequency")

# now, fewer zeros
# more values in middle
# not perfect poisson distribution, was randomly generated (changes each time)
# gives idea of what our data should look like
# now, looks right-skewed, but variance might be larger than mean so use goodness of fit

# For our data, is the mean equal to the variance?
var(mydata$num.awards) # 1.108643

#----------------------------------------------------------------------------------------------

######################
# DATA VISUALIZATION
######################

# 4. Create a scatterplot of the response variable against the continuous explanatory variable with a lowess line. Does this indicate that math score would be a good explanatory variable? (1 mark)

# What is the potential relationship between carapace width and satellite males?
plot(num.awards ~ math, data=mydata, pch=16, main = "Number of Awards Vs. Final Math Exam Mark", xlab="Final Math Exam Mark", ylab="Number of Awards")
lines(lowess(mydata$math, mydata$num.awards, delta = 0.1), col = "red")
# higher math marks indicate higher number of awards
# since the data is scattered, it seems as though it's hard to conclude the math score is a good explanatory variable
# it would be difficult to create a MLR as the assumptions would be hard to meet

#----------------------------------------------------------------------------------------------

# 5. Create a grouped bar plot that shows the frequency of different responses, grouped by program. Does it look like each category level follows a Poisson distribution? In the caption, explain how each category level is represented on the graph. (1 mark)

# Plot the response variable against program (a categorical variable)

barplot(table(mydata$program, mydata$num.awards), beside=TRUE, col=c("darkblue","red", "darkgreen"), main = "Number of Students Vs. Number of Awards", xlab="Number of Awards", ylab="Frequency of Responses")
legend(20, 40, legend=c("General", "Academic", "Vocational"),
       col=c("Blue", "Red", "Green"), pch=16:16, cex=0.8)
# yes, the response variable against the programs (i.e. 1, 2, 3) do appear as Poission distributions.

#----------------------------------------------------------------------------------------------

# 6. What is the mean of awards received per student for the different programs (general, academic, vocational)? Use the tapply function for this. Does this indicate that program would be a good explanatory variable? (0.5 marks)

tapply(mydata$num.awards, mydata$program, mean)
# 1    2    3 
# 0.20 1.00 0.24 

prog.means <- tapply(mydata$num.awards, mydata$prog, FUN = "mean")
prog.means

# yes, it would be a good explanatory variable because academic is expected to be the highest

#----------------------------------------------------------------------------------------------

# 7. Fit a null model. What is the value of the intercept? Backtransform this value using the appropriate backtransformation for Poisson regression. What does this value represent? (0.5 marks)

###############
# MODELS
###############

# null model
mean(mydata$num.awards) # 0.63

z.null <- glm(num.awards ~ 1, data=mydata, family="poisson"(link="log"))
summary(z.null)

# intercept = -0.46204
exp(-0.46204) # 0.6299971

# the value represents the mean value of the null model given the num.awards
# the vaule is ~ the mean of num.awards

#----------------------------------------------------------------------------------------------

# 8. Fit a model with math score as the explanatory variable (Model A). Test the significance of the regression using a likelihood ratio test (include all four steps of your hypothesis test). Write the full calculation for the likelihood ratio test statistic (based on log likelihood values from R). (1 mark)

# create a model using math score
plot(num.awards ~ math, data=mydata, pch=16)
lines(lowess(mydata$math, mydata$num.awards))

z.1 <- glm(num.awards ~ math, data=mydata, family="poisson"(link="log"))
summary(z.1)
# here, see the residual variance and dfs****

# test the significance of the model (compare to null model)
anova(z.1, z.null, test="Chi")
# p = 2.2e-16
# significant, so better than null model, so candidate of x possible

# Step 1:
# H0: No difference between the two models (restriction is justified -> use simpler model)
# H1: The two models have significantly different likelihoods (restriction is not justified -> use more complex model)

# Step 2: Calculate the G-statistic
-2*(logLik(z.null)-logLik(z.1))
# 'log Lik.' 83.65093 (df=1)

# Step 3: Compare the Chi-statistic
# p-value = 2.2e-16 < a = 0.05
# X^1(1,1-0.05) = 3.84 < G = 83.65093

# Step 4: Therefore, the regression is significant. Iw ill reject the null hypothesis and so go with the more complex model which includes math marks as an explanatory variable. 

#----------------------------------------------------------------------------------------------

# 9. Fit a model with math score and program as explanatory variables (Model B); include the interaction term. Test the significance of the regression using a likelihood ratio test. Test the significance of the regression using a likelihood ratio test (include all four steps of your hypothesis test). Write the full calculation for the likelihood ratio test statistic (based on log likelihood values from R). (1 mark)

z.2 <- glm(num.awards ~ math + program + math*program, data=mydata, family="poisson"(link="log"))
summary(z.2)
# here, see the residual variance and dfs****

# test the significance of the model (compare to null model)
anova(z.2, z.null, test="Chi")
# p = 2.2e-16
# significant, so better than null model, so candidate of x possible

# Step 1: Hypothesis
# H0: No difference between the two models (restriction is justified -> use simpler model)
# H1: The two models have significantly different likelihoods (restriction is not justified -> use more complex model)

# Step 2: Calculate the G-statistic
-2*(logLik(z.null)-logLik(z.2))
# 'log Lik.' 98.57062 (df=1)

# Step 3: Compare the Chi-statistic
# p-value = 2.2e-16 < a = 0.05
# X^1(3,1-0.05) = 7.81 < G = 98.57062

# Step 4: Therefore, the regression is significant. Iw ill reject the null hypothesis and so go with the more complex model which includes math marks, one's program type, and the interaction between math and one's program type as the explanatory variable.s 

#----------------------------------------------------------------------------------------------

# 10. Test each variable in Model B using likelihood ratio tests (include all four steps of your hypothesis test). Write the full calculation for the likelihood ratio test statistic (based on log likelihood values from R). What do you conclude about the explanatory variables in Model B? Is model B a good model? (2 marks)

# z.1 <- glm(num.awards ~ math, data=mydata, family="poisson"(link="log"))
# y = bo + b1*math  (df = 1)
# z.2 <- glm(num.awards ~ math + program + math*program, data=mydata, family="poisson"(link="log"))
# y = bo + b1*prog.1 + b2*prog.2 + b3*math + b4*prog.1*math + b5*prog.2*math    (df = 5)
#           x1 x2
# level 3   1  0
# level 2   0  1
# level 1   0  0  
z.3 <- glm(num.awards ~ program, data=mydata, family="poisson"(link="log"))
# y = bo + b1*prog.1 + b2*prog.2    (df = 3)

### COMPARING MODELS 1 AND 2

# HO: No difference between the two models (restriction is justified so use simpler model)
# H1: The two models have significantly different likelihoods (restriction is not justified os use more complex model)

# Step 2: Calculate G-statistic
-2*(logLik(z.1)-logLik(z.2))
# 'log Lik.' 14.91968

# Step 3: Compare to Chi-statistic
anova(z.2, z.1, test="Chi")
# p-value = 0.004871) < (a = 0.05) 
# (X^2,4,1-a) = 9.49 < 14.91968

# Step 4: Therefore, the more complex model is significantly better. I reject the null hypothesis and the so go with more complex model which includes the variable math mark in model.

### COMPARING MODELS 3 AND 2

# Step 1: Hypothesis
# H0: No difference between the two models (restriction is justified so use simpler model)
# H1: The two models have significantly different likelihoods (restriction is not justified so use more complex model)

# Step 2: Calculate G-statistic
-2*(logLik(z.3)-logLik(z.2))
# 'log Lik.' 45.35836 (df=3)
# the df carried over so you cannot predict the df value, so ignore this df
# still just count the number of terms you drop

# Step 3: Compare to Chi-statistic 
anova(z.2, z.3, test="Chi")
# p-value = 0.004871) < (a = 0.05) 
# (X^2,3,1-a) = 7.81 < 45.35836

# Step 4: Therefore, the more complex model is significantly better. I reject the null hypothesis and the so go with more complex model which includes the variable program in model.

#----------------------------------------------------------------------------------------------

# 11. Fit a model with math score and program as explanatory variables excluding the interaction term (Model C). Test the significance of the interaction term using a likelihood ratio test comparing model B and C. (1 mark)

z.4 <- glm(num.awards ~ math + program, data=mydata, family="poisson"(link="log"))
# y = bo + b1*prog.1 + b2*prog.2 + b3*math (df = 3)
#           x1 x2
# level 3   1  0
# level 2   0  1
# level 1   0  0  

### COMPARING MODELS 4 AND 2

# Step 1: Hypothesis
# H0: No difference between the two models (restriction is justified so use simpler model)
# H1: The two models have significantly different likelihoods (restriction is not justified so use more complex model)

# Step 2: Calculate G-statistic
-2*(logLik(z.4)-logLik(z.2))
# 'log Lik.' 0.3480014 (df=4)
# the df carried over so you cannot predict the df value, so ignore this df
# still just count the number of terms you drop

# Step 3: Compare to Chi-statistic 
anova(z.2, z.4, test="Chi")
# p-value = 0.8403) > (a = 0.05)
# (X^1,4,1-a) = 3.84 > 0.3480014

# Step 4: Therefore, the less complex model is significantly better. I fail to reject the null hypothesis and the so go with less complex model which includes the variables math mark and program in model but not the interaction term.

#----------------------------------------------------------------------------------------------

# 12. Write the equation of the final model with the values of the co-efficients. (1 mark)

# num.awards = bo + b1*prog.1 + b2*prog.2 + b3*math (df = 3)
#           x1 x2
# level 3   1  0
# level 2   0  1
# level 1   0  0  
summary(z.4)
# Coefficients:
# Estimate Std. Error z value Pr(>|z|)    
#    (Intercept) -5.24712    0.65845  -7.969 1.60e-15 ***
#    math         0.07015    0.01060   6.619 3.63e-11 ***
#    program2     1.08386    0.35825   3.025  0.00248 ** 
#    program3     0.36981    0.44107   0.838  0.40179        

# Equation: ln(num.awards)_hat = -5.24712 + 0.07015*math + 1.08386*prog.2 + 0.36981*prog.3
# programs 1 and 3 are not statistically different

#----------------------------------------------------------------------------------------------

# 13. Define the terms overdispersion and underdispersion (use graphs or sketches to supplement your explanation). (1 mark)

# slide 13

#----------------------------------------------------------------------------------------------

# 14. Calculate the residual deviance / degrees of freedom. Do you see any evidence for overdispersion or underdispersion in your final model? (1 mark)

# Does the model have overdispersion?
summary(z.4)
# (Dispersion parameter for poisson family taken to be 1)
# Null deviance: 287.67  on 199  degrees of freedom
# Residual deviance: 189.45  on 196  degrees of freedom
# AIC: 373.5
residual.deviance.df = 189.45/196
residual.deviance.df
# [1] 0.9665816
# Residual deviance / df < 1.5
# therefore, our value is < 1.5 so we do not have evidence for overdispersion

# regarding underdispersion, we seek values that well below 1, here it is not low enough

#----------------------------------------------------------------------------------------------

# 15. Create a scatterplot of the response variable against the math score with program shown in different colors. Add the lines (in the matching color) of the model fit. (1 mark)

############################
# PLOTS TO SHOW MODEL FIT
############################

# PLOT WITH MODEL FIT

xnew <- seq(min(mydata$math), max(mydata$math), length.out = 100)
xnew

# bind rows of 3 levels which must be data frames
xnew.2 <- rbind(as.data.frame(xnew), as.data.frame(xnew), as.data.frame(xnew))

# now assign program number to each section
programs <- as.data.frame(c(rep(1, 100), rep(2,100), rep(3,100)))

# now column bind 
new.data <- cbind(xnew.2, programs)
# now give fancy column names
names(new.data) <- c("math", "program")
new.data$program <- as.factor(new.data$program)

ynew <- predict(z.4, data.frame(new.data), type="response")
ynew

new.data.2 <- cbind(new.data, ynew)

plot(num.awards ~ math, data=mydata, pch=16)

# Subset the new data into the different colors
mydata.col.1 <- subset(new.data.2, new.data.2$program == "1")
mydata.col.2 <- subset(new.data.2, new.data.2$program == "2")
mydata.col.3 <- subset(new.data.2, new.data.2$program == "3")

# Plot the data and model fit with color coding
plot(num.awards ~ math, data=mydata, pch=16, col = c("red", "blue", "green")[as.factor(mydata$program)], main = "Number of Awards Vs. Final Math Exam Mark", xlab="Final Math Exam Mark", ylab="Number of Awards")
legend(35, 6, legend=c("Academic", "General", "Vocational"),
       col=c("Blue", "Red", "Green"), pch=16:16, cex=0.8)
lines(mydata.col.1$math, mydata.col.1$ynew, lty=1, col="red")
lines(mydata.col.2$math, mydata.col.2$ynew, lty=1, col="blue")
lines(mydata.col.3$math, mydata.col.3$ynew, lty=1, col="green")

#----------------------------------------------------------------------------------------------

# 16. What are your observations from the graph? How do these observations relate to the co-efficients from the model? (2 marks)

#----------------------------------------------------------------------------------------------

# 17. The school is wondering about adding 5 new scholarships. Give your opinion about how the scholarships should be distributed among the programs. Discuss: how the program(s) you chose would benefit the most from the additional scholarships, and which criteria should be used for determining who receives the scholarship. Justify your opinion based on the results of your analyses and how you define the primary objective when giving scholarships. (2 marks)