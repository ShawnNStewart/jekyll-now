##Replication Project
#Shawn Stewart

#clear the environment
rm(list=ls())

#load the libraries
library("car")
library("oddsratio")
library("dplyr")
library("tidyr")
library("lubridate")
library("tidyverse")
library("janitor")

#set the working directory
setwd("C:/Users/Owner/OneDrive - The University of Texas at Dallas/My Program/EPPS 6316 - Regression/Project")

#load data
COVID_raw <- read.delim("C:/Users/Owner/OneDrive - The University of Texas at Dallas/My Program/EPPS 6316 - Regression/Project/Dataset.txt")

# outlier variables to NA
COVID_clean <- COVID_raw
COVID_clean$localsiphours[COVID_clean$localsiphours == 528] <-NA 
COVID_data<-COVID_clean

###------------------------------CREATE NEW VARIABLES-------------------------------------------------###

COVID_data$Classification <- as.factor(COVID_data$Classification)


attach(COVID_data)

##factor sex and create labels
(sexf<- factor(sex))
(sexf <-factor(sex, labels= c("Male", "Female")))

## create age categories and turn to categorical variable
agegroup = cut(COVID_data$age, breaks= c(18,34,49,150)) 
levels(agegroup) = c("18-34", "35-49", ">=50")

## create household income (hhiincome) categories and turn to categorical variable
# 1,2,3,4,5 (<50,000k) 
# 6,7,8,9,10 (50k to <100K)  
# 11 (100k to 150k) 
# 12 (>150k) 
(hhincomef <- factor(hhincome))
(hhincomef <-factor(hhincome, labels =c ("<50k", "<50k", "<50k", "<50k", "<50k","50-<100k","50-<100k","50-<100k", "50-<100k", "50-<100k", "100-150k", ">150k")))


## create new children binary variable (code as yes/no)
#0=no children
#1-6 = yes children
(childrenf<- factor(hhchildren))
(childrenf <-factor(hhchildren, labels= c("No", "Yes", "Yes","Yes","Yes","Yes", "Yes")))

## create new education binary variable
#1,3,4,5,7 = not a college graduate
#6 = college or more
(educf<-factor(educ))
(educf<-factor(educ, labels = c("Notcollegegraduate", "Notcollegegraduate", "Notcollegegraduate", "College","Notcollegegraduate")))

## create new depression score binary variable
# none or mild = 0
# moderate or severe = 1
COVID_data <- COVID_data %>%
  mutate(depression_dichot= case_when(phq_sum <=9 ~ 0,
                                      phq_sum >=10 ~ 1))

## create new employment binary variable
# employed or student (1,2,6)
# unemployed or other (3,4,5,7,8)
(employf<-factor(employ1))
(employf<-factor(employ1, labels = c("employed", "employed", "unemployed", "unemployed","unemployed", "employed","unemployed","unemployed")))

COVID_data <- COVID_data %>%
  mutate(essentialnew= case_when(employ1 ==1 & essntlsrvcs== 1 ~ 1,
                                 employ1 ==1 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==1 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==2 & essntlsrvcs== 1 ~ 1,
                                 employ1 ==2 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==2 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==3 & essntlsrvcs== 1 ~ 2,
                                 employ1 ==3 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==3 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==4 & essntlsrvcs== 1 ~ 2,
                                 employ1 ==4 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==4 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==5 & essntlsrvcs== 1 ~ 2,
                                 employ1 ==5 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==5 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==6 & essntlsrvcs== 1 ~ 1,
                                 employ1 ==6 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==6 & essntlsrvcs== 7 ~ 2,
                                 
                                 
                                 employ1 ==7 & essntlsrvcs== 1 ~ 2,
                                 employ1 ==7 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==7 & essntlsrvcs== 7 ~ 2,
                                 
                                 employ1 ==8 & essntlsrvcs== 1 ~ 2,
                                 employ1 ==8 & essntlsrvcs== 2 ~ 2,
                                 employ1 ==8 & essntlsrvcs== 7 ~ 2,))


(essentialnewf<-factor(COVID_data$essentialnew))
(essentialnewf<-factor(COVID_data$essentialnew, labels = c("essential", "nonessential")))

## create new race/ethnicity binary variable
#nonwhite=1
#nonhispanicwhite=2
COVID_data <- COVID_data %>%
  mutate(racenew= case_when(ethnicity ==1 & race== 0 ~ 1,
                            ethnicity ==1 & race== 1 ~ 1,
                            ethnicity ==1 & race== 2 ~ 1,
                            ethnicity ==1 & race== 3 ~ 1,
                            ethnicity ==1 & race== 4 ~ 1,
                            ethnicity ==1 & race== 5 ~ 1,
                            ethnicity ==1 & race== 6 ~ 1,
                            ethnicity ==2 & race== 0 ~ 1,
                            ethnicity ==2 & race== 1 ~ 1,
                            ethnicity ==2 & race== 2 ~ 1,
                            ethnicity ==2 & race== 3 ~ 1,
                            ethnicity ==2 & race== 4 ~ 2,
                            ethnicity ==2 & race== 5 ~ 1,
                            ethnicity ==2 & race== 6 ~ 1,))


(racenewf<-factor(COVID_data$racenew))
(racenewf<-factor(COVID_data$racenew, labels = c("nonwhite", "nonhispanicwhite")))                         
levels(racenewf)


## create new depression severity binary variable
(depressionnewf<-factor(COVID_data$depression_dichot))
(depressionnewf<- factor(COVID_data$depression_dichot, labels = c("noneormild", "moderateorsevere")))
levels(depressionnewf)


## create new variable for localsiphours (>= 23 hours at home)
#compliant = 1
#notcompliant = 0

COVID_data<-COVID_data %>%
  mutate(localsiphours_1 = case_when(localsiphours >=23 ~1,
                                     localsiphours <=22 ~ 0))


## create a new variable that is a sum of leavehomeact variables and spending time at home#
COVID_data <- COVID_data %>%
  mutate(leavehomeacttotnew = leavehomeact___1+leavehomeact___2+leavehomeact___3+leavehomeact___4+leavehomeact___5+leavehomeact___6+localsiphours_1)


## create a new variable that is a sum of leavehome variables#
COVID_data <- COVID_data %>%
  mutate(leavehometotnew = leavehomereason___1+leavehomereason___3+leavehomereason___4+leavehomereason___5+leavehomereason___6)

COVID_data <- data.frame(COVID_data, sexf, agegroup, hhincomef, educf, racenewf, childrenf, depressionnewf)


###------------------------------ANALYSIS-------------------------------------------------###
# filter out missing zip, covid sick outcome if still sick, and limited functioning 
COVID_data_sample <- COVID_data %>%
  filter(localsip==1) %>%
  filter(!is.na(zip)) %>%
  filter(is.na(covidsickoutcome) | covidsickoutcome !=2) %>%
  filter(is.na(dis_alone) | dis_alone !=1) 

### filter out not essential workers
COVID_data_notessential <- COVID_data_sample %>%
  filter(is.na(essntlsrvcs) | essntlsrvcs !=1)

## descriptive analyses for each characteristic
summary(COVID_data_notessential$age, na.rm=TRUE)
sd(COVID_data_notessential$age, na.rm=TRUE)

tabyl(COVID_data_notessential$state, sort = true)

tabyl(COVID_data_notessential$Classification, sort = true)

tabyl(COVID_data_notessential$sexf, sort = true)

tabyl(COVID_data_notessential$racenewf, sort = true)

tabyl(COVID_data_notessential$agegroup, sort = true)

tabyl(COVID_data_notessential$educf, sort = true)

tabyl(COVID_data_notessential$hhincomef, sort = true)

tabyl(COVID_data_notessential$childrenf, sort = true)

tabyl(COVID_data_notessential$depression_dichot, sort = true)

tabyl(COVID_data_notessential$comorbid, sort = true)

summary(COVID_data_notessential$leavehometotnew)
sd(COVID_data_notessential$leavehometotnew)

summary(COVID_data_notessential$leavehomeacttotnew, na.rm=TRUE)
sd(COVID_data_notessential$leavehomeacttotnew, na.rm=TRUE)


### frequencies for reasons for leaving home ###
tabyl(COVID_data_notessential$leavehomereason___1, sort = true)

tabyl(COVID_data_notessential$leavehomereason___3, sort = true)

tabyl(COVID_data_notessential$leavehomereason___4, sort = true)

tabyl(COVID_data_notessential$leavehomereason___5, sort = true)

tabyl(COVID_data_notessential$leavehomereason___6, sort = true)


### frequencies for public health practices###
tabyl(COVID_data_notessential$leavehomeact___1, sort = true)

tabyl(COVID_data_notessential$leavehomeact___2, sort = true)

tabyl(COVID_data_notessential$leavehomeact___3, sort = true)

tabyl(COVID_data_notessential$leavehomeact___4, sort = true)

tabyl(COVID_data_notessential$leavehomeact___5, sort = true)

tabyl(COVID_data_notessential$leavehomeact___6, sort = true)

tabyl(COVID_data_notessential$localsiphours_1, sort = true)


####### logisitic regression #######

## check reference and levels for each categorical variable
contrasts(Classification) 
contrasts(agegroup)
contrasts(hhincomef)
contrasts(childrenf)
contrasts(depressionnewf)
contrasts(educf)

## create new comorbid binary variable 
comorbidf <- factor(COVID_data_notessential$comorbid)
levels(comorbidf) = c("1 or more", "None")
contrasts(comorbidf)

## change reference for comorbid and depression severity 
comorbidf_relevel <- relevel(comorbidf, ref = "None")
COVID_data_notessential$depression_dichotf <- factor(COVID_data_notessential$depression_dichot)
levels(COVID_data_notessential$depression_dichotf) = c("Mildnone", "Modsevere")

## change reference categories for categorical variables
Classification1 <-relevel(COVID_data_notessential$Classification, ref="Urban")
levels(Classification1)

edu1 <-relevel(COVID_data_notessential$educf, ref="College")
levels(edu1)
class(leavehomereason___1)

### Adjusted logistic regression For Leaving Home and association with each characteristic ###
# work
fullmodwork <- glm(leavehomereason___1 ~ Classification1 + sexf + agegroup + edu1 + hhincomef + childrenf + depression_dichotf + comorbidf_relevel, 
                    data = COVID_data_notessential,
                    family = "binomial")
summary(fullmodwork)
##multicollinearity##
vif(fullmodwork) 
or_glm(data=COVID_data_notessential, model=fullmodwork)


# grocery shopping
fullmodgrocery <- glm(leavehomereason___3 ~ Classification1 + sexf + agegroup + edu1 + hhincomef + childrenf + depression_dichotf + comorbidf_relevel, 
                       data = COVID_data_notessential,
                       family = "binomial")
summary(fullmodgrocery)
##multicollinearity##
vif(fullmodgrocery) 
or_glm(data=COVID_data_notessential,model=fullmodgrocery)


# other essential shopping
fullmodothershop <- glm(leavehomereason___4 ~ Classification1 + sexf + agegroup + edu1 + hhincomef + childrenf + depression_dichotf + comorbidf_relevel, 
                         data = COVID_data_notessential,
                         family = "binomial")
summary(fullmodothershop)
##multicollinearity##
vif(fullmodothershop)
or_glm(data=COVID_data_notessential,model=fullmodothershop)


# exercise
fullmodexercise <- glm(leavehomereason___5 ~ Classification1 + sexf + agegroup + edu1 + hhincomef + childrenf + depression_dichotf + comorbidf_relevel, 
                        data = COVID_data_notessential,
                        family = "binomial")
summary(fullmodexercise)
##multicollinearity##
vif(fullmodexercise)
or_glm(data=COVID_data_notessential,model=fullmodexercise)


# walking dog
fullmoddog <- glm(leavehomereason___6 ~ Classification1 + sexf + agegroup + edu1 + hhincomef + childrenf + depression_dichotf + comorbidf_relevel, 
                   data = COVID_data_notessential,
                   family = "binomial")
summary(fullmoddog)
##multicollinearity##
vif(fullmoddog) 
or_glm(data=COVID_data_notessential,model=fullmoddog)


##Adjusted logistic regression model Protective Health Behaviors and association with each characteristic ##
# spending at least 2-3 hours inside home
fullmodLeaveHome <- glm(localsiphours_1 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                         data = COVID_data_notessential,
                         family = "binomial")
summary(fullmodLeaveHome)
#multicollinearity
vif(fullmodLeaveHome) 
or_glm(data=COVID_data_notessential,model=fullmodLeaveHome)


# physical/social distancing
fullmodSocialDist <- glm(leavehomeact___1 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                          data = COVID_data_notessential,
                          family = "binomial")
summary(fullmodSocialDist)
##multicollinearity##
vif(fullmodSocialDist)
or_glm(data=COVID_data_notessential,model=fullmodSocialDist)


# protective mask
fullmodMask <- glm(leavehomeact___2 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                    data = COVID_data_notessential,
                    family = "binomial")
summary(fullmodMask)
##multicollinearity##
vif(fullmodMask)
or_glm(data=COVID_data_notessential,model=fullmodMask)


# wearing gloves
fullmodGloves <- glm(leavehomeact___3 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                      data = COVID_data_notessential,
                      family = "binomial")
summary(fullmodGloves)
##multicollinearity##
vif(fullmodGloves)
or_glm(data=COVID_data_notessential,model=fullmodGloves)


# using hand sanitizer
fullmodSanitizer <- glm(leavehomeact___4 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                        data = COVID_data_notessential,
                        family = "binomial")
summary(fullmodSanitizer)
##multicollinearity##
vif(fullmodSanitizer) 
or_glm(data=COVID_data_notessential,model=fullmodSanitizer)


# using disinfectant wipes
fullmodWipes<- glm(leavehomeact___5 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                    data = COVID_data_notessential,
                    family = "binomial")
summary(fullmodWipes)
##multicollinearity##
vif(fullmodWipes) 
or_glm(data=COVID_data_notessential,model=fullmodWipes)


# washing hands frequently
fullmodHands<- glm(leavehomeact___6 ~ Classification1 + sexf + agegroup + hhincomef + edu1 + childrenf + depression_dichotf + comorbidf_relevel, 
                    data = COVID_data_notessential,
                    family = "binomial")
summary(fullmodHands)
##multicollinearity##
vif(fullmodHands) 
or_glm(data=COVID_data_notessential,model=fullmodHands)

###########EXTENSION##########################################################
#tables and visualization of the variable

#using the same data, filtered the same way
mydata <- COVID_data_notessential

#break out comborbidities individually
tabyl(COVID_data_notessential$comborbid_heartattack, sort = true)
tabyl(COVID_data_notessential$comborbid_chd, sort = true)
tabyl(COVID_data_notessential$comborbid_stroke, sort = true)
tabyl(COVID_data_notessential$comborbid_asthma, sort = true)
tabyl(COVID_data_notessential$comborbid_skincancer, sort = true)
tabyl(COVID_data_notessential$comborbid_othcancer, sort = true)
tabyl(COVID_data_notessential$comborbid_copd, sort = true)
tabyl(COVID_data_notessential$comborbid_arthritis, sort = true)
tabyl(COVID_data_notessential$comborbid_kidneydis, sort = true)
tabyl(COVID_data_notessential$comborbid_depression, sort = true)
tabyl(COVID_data_notessential$comborbid_diabetes, sort = true)
tabyl(COVID_data_notessential$comborbid_obesity, sort = true)
tabyl(COVID_data_notessential$comborbid_parkinsons, sort = true)
tabyl(COVID_data_notessential$comborbid_alzheimers, sort = true)

#want to see # of comorbidities as a new variable 
#first, turn at NA into 0

mydata$comborbid_alzheimers[which(is.na(mydata$comborbid_alzheimers))] <- 0 
mydata$comborbid_arthritis[which(is.na(mydata$comborbid_arthritis))] <-0
mydata$comborbid_asthma[which(is.na(mydata$comborbid_asthma))]   <-0
mydata$comborbid_chd[which(is.na(mydata$comborbid_chd))]   <-0
mydata$comborbid_copd[which(is.na(mydata$comborbid_copd))]   <-0
mydata$comborbid_depression [which(is.na(mydata$comborbid_depression))] <- 0 
mydata$comborbid_diabetes [which(is.na(mydata$comborbid_diabetes))] <- 0 
mydata$comborbid_heartattack [which(is.na(mydata$comborbid_heartattack))] <- 0 
mydata$comborbid_kidneydis [which(is.na(mydata$comborbid_kidneydis))] <- 0 
mydata$comborbid_obesity [which(is.na(mydata$comborbid_obesity))] <- 0 
mydata$comborbid_othcancer [which(is.na(mydata$comborbid_othcancer))] <- 0 
mydata$comborbid_parkinsons [which(is.na(mydata$comborbid_parkinsons))] <- 0 
mydata$comborbid_skincancer [which(is.na(mydata$comborbid_skincancer))] <- 0 
mydata$comborbid_stroke [which(is.na(mydata$comborbid_stroke))] <- 0 

#count number of comorbidities

mydata$comorbid_count <- as.numeric(mydata$comborbid_alzheimers)+as.numeric(mydata$comborbid_arthritis)+as.numeric(mydata$comborbid_asthma)+as.numeric(mydata$comborbid_chd)+as.numeric(mydata$comborbid_copd)+as.numeric(mydata$comborbid_depression)+as.numeric(mydata$comborbid_diabetes)+as.numeric(mydata$comborbid_heartattack)+as.numeric(mydata$comborbid_kidneydis)+as.numeric(mydata$comborbid_obesity)+as.numeric(mydata$comborbid_othcancer)+as.numeric(mydata$comborbid_parkinsons)+as.numeric(mydata$comborbid_skincancer)+as.numeric(mydata$comborbid_stroke)
table(mydata$comorbid_count)

#Analysis With Four Categories===============================================================

#create a "categories" variable that splits comorbidity into 1, 2, or 3 or more. 
mydata$comorbid_cat <- mydata$comorbid_count
mydata$comorbid_cat[which(mydata$comorbid_cat>=3)] <- 3
table(mydata$comorbid_cat)

#create a new factor variable for the comorbidities category
## create new comorbid binary variable 
mydata$comorbidcatf <- factor(mydata$comorbid_cat)
levels(mydata$comorbidcatf) = c("None","One","Two","Three or more")
contrasts(mydata$comorbidcatf)

tablecomorbid_cat <- table(mydata$comorbidcatf)

## change reference for comorbid categories
mydata$comorbidcatf <- relevel(mydata$comorbidcatf, ref = "None")


#looking at the counts with boxplot, histogram
barplot(tablecomorbid_cat, xlab="# of comorbid conditions")
boxplot(mydata$comorbid_cat,ylab="# of comorbid conditions")


#leaving home models--------------------------------------------------------------------------------------
### Adjusted logistic regression For Leaving Home and association with each characteristic###
#re-run the logistic regression for each outcome of interest, using this new category for comorbidities instead 

# work
myfullmodwork <- glm(mydata$leavehomereason___1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                    data = mydata,
                    family = "binomial")
summary(myfullmodwork)
##multicollinearity##
vif(myfullmodwork) 
or_glm(data=mydata,model=myfullmodwork)

# grocery shopping
myfullmodgrocery <- glm(leavehomereason___3 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                       data = mydata,
                       family = "binomial")
summary(myfullmodgrocery)
##multicollinearity##
vif(myfullmodgrocery) 
or_glm(data=mydata,model=myfullmodgrocery)


# other essential shopping
myfullmodothershop <- glm(leavehomereason___4 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                         data = mydata,
                         family = "binomial")
summary(myfullmodothershop)
vif(myfullmodothershop)
or_glm(data=mydata,model=myfullmodothershop)


# exercise
myfullmodexercise <- glm(leavehomereason___5 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                        data = mydata,
                        family = "binomial")
summary(myfullmodexercise)
##multicollinearity##
vif(myfullmodexercise)
or_glm(data=mydata,model=myfullmodexercise)


# walking dog
myfullmoddog <- glm(leavehomereason___6 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                   data = mydata,
                   family = "binomial")
summary(myfullmoddog)
##multicollinearity##
vif(myfullmoddog) 
or_glm(data=mydata,model=myfullmoddog)


#protective behaviors models---------------------------------------------------------------------------
##Adjusted logistic regression model Protective Health Behaviors and association with each characteristic ##
# spending at least 23 hours inside home
myfullmodLeaveHome <- glm(localsiphours_1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                         data = mydata,
                         family = "binomial")
summary(fullmodLeaveHome)
#multicollinearity
vif(myfullmodLeaveHome) 
or_glm(data=mydata,model=myfullmodLeaveHome)


# physical/social distancing
myfullmodSocialDist <- glm(leavehomeact___1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                          data = mydata,
                          family = "binomial")
summary(myfullmodSocialDist)
##multicollinearity##
vif(myfullmodSocialDist)
or_glm(data=mydata,model=myfullmodSocialDist)


# protective mask
myfullmodMask <- glm(leavehomeact___2 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                    data = mydata,
                    family = "binomial")
summary(myfullmodMask)
##multicollinearity##
vif(myfullmodMask)
or_glm(data=mydata,model=myfullmodMask)

# wearing gloves
myfullmodGloves <- glm(leavehomeact___3 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                      data = mydata,
                      family = "binomial")
summary(myfullmodGloves)
##multicollinearity##
vif(myfullmodGloves)
or_glm(data=mydata,model=myfullmodGloves)


# using hand sanitizer
myfullmodSanitizer <- glm(leavehomeact___4 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                        data = mydata,
                        family = "binomial")
summary(myfullmodSanitizer)
##multicollinearity##
vif(myfullmodSanitizer) 
or_glm(data=mydata,model=myfullmodSanitizer)


# using disinfectant wipes
myfullmodWipes<- glm(leavehomeact___5 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                    data = mydata,
                    family = "binomial")
summary(myfullmodWipes)
##multicollinearity##
vif(myfullmodWipes) 
or_glm(data=mydata,model=myfullmodWipes)


# washing hands frequently
myfullmodHands<- glm(leavehomeact___6 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf, 
                    data = mydata,
                    family = "binomial")
summary(myfullmodHands)
##multicollinearity##
vif(myfullmodHands) 
or_glm(data=mydata,model=myfullmodHands)


#Generated a strange coefficient for the social distancing regression. 
#Looking at table of values to see if complete separation is happening
table(mydata$comorbidcatf,mydata$leavehomeact___1)

#Analysis with Three Categories ====================================================================

#create a variable that splits comorbidity into 0, 1, or 2 or more. 
mydata$comorbid_cat2 <- mydata$comorbid_count
mydata$comorbid_cat2[which(mydata$comorbid_cat2>=2)] <- 2
table(mydata$comorbid_cat2)

#create a new factor variable for the comorbidities category
## create new comorbid binary variable 
mydata$comorbidcatf2 <- factor(mydata$comorbid_cat2)
levels(mydata$comorbidcatf2) = c("None","One","Two or more")
contrasts(mydata$comorbidcatf2)

tablecomorbid2 <- table(mydata$comorbidcatf2)

## change reference for comorbid categories
mydata$comorbidcatf2 <- relevel(mydata$comorbidcatf2, ref = "None")


#looking at the counts with boxplot, barplot, for three bins
barplot(tablecomorbid2, xlab="# of comorbid conditions")
boxplot(mydata$comorbid_cat2,ylab="# of comorbid conditions")


#leaving home models--------------------------------------------------------------------------------------
### Adjusted logistic regression For Leaving Home and association with each characteristic###
#re-run the logistic regression for each outcome of interest, using this 3-category comorbidities variable instead 

# work
myfullmodwork2 <- glm(mydata$leavehomereason___1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                     data = mydata,
                     family = "binomial")
summary(myfullmodwork2)
##multicollinearity##
vif(myfullmodwork2) 
or_glm(data=mydata,model=myfullmodwork2)

# grocery shopping
myfullmodgrocery2 <- glm(leavehomereason___3 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                        data = mydata,
                        family = "binomial")
summary(myfullmodgrocery2)
##multicollinearity##
vif(myfullmodgrocery2) 
or_glm(data=mydata,model=myfullmodgrocery2)


# other essential shopping
myfullmodothershop2 <- glm(leavehomereason___4 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                          data = mydata,
                          family = "binomial")
summary(myfullmodothershop2)
vif(myfullmodothershop2)
or_glm(data=mydata,model=myfullmodothershop2)


# exercise
myfullmodexercise2 <- glm(leavehomereason___5 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                         data = mydata,
                         family = "binomial")
summary(myfullmodexercise2)
##multicollinearity##
vif(myfullmodexercise2)
or_glm(data=mydata,model=myfullmodexercise2)


# walking dog
myfullmoddog2 <- glm(leavehomereason___6 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                    data = mydata,
                    family = "binomial")
summary(myfullmoddog2)
##multicollinearity##
vif(myfullmoddog2) 
or_glm(data=mydata,model=myfullmoddog2)


#protective behaviors models---------------------------------------------------------------------------
##Adjusted logistic regression model Protective Health Behaviors and association with each characteristic ##
# spending at least 23 hours inside home
myfullmodLeaveHome2 <- glm(localsiphours_1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                          data = mydata,
                          family = "binomial")
summary(myfullmodLeaveHome2)
#multicollinearity
vif(myfullmodLeaveHome2) 
or_glm(data=mydata,model=myfullmodLeaveHome2)


# physical/social distancing
myfullmodSocialDist2 <- glm(leavehomeact___1 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                           data = mydata,
                           family = "binomial")
summary(myfullmodSocialDist2)
##multicollinearity##
vif(myfullmodSocialDist2)
or_glm(data=mydata,model=myfullmodSocialDist2)


# protective mask
myfullmodMask2 <- glm(leavehomeact___2 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                     data = mydata,
                     family = "binomial")
summary(myfullmodMask2)
##multicollinearity##
vif(myfullmodMask2)
or_glm(data=mydata,model=myfullmodMask2)


# wearing gloves
myfullmodGloves2 <- glm(leavehomeact___3 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                       data = mydata,
                       family = "binomial")
summary(myfullmodGloves2)
##multicollinearity##
vif(myfullmodGloves2)
or_glm(data=mydata,model=myfullmodGloves2)


# using hand sanitizer
myfullmodSanitizer2 <- glm(leavehomeact___4 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                          data = mydata,
                          family = "binomial")
summary(myfullmodSanitizer2)
##multicollinearity##
vif(myfullmodSanitizer2) 
or_glm(data=mydata,model=myfullmodSanitizer2)


# using disinfectant wipes
myfullmodWipes2<- glm(leavehomeact___5 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                     data = mydata,
                     family = "binomial")
summary(myfullmodWipes2)
##multicollinearity##
vif(myfullmodWipes2) 
or_glm(data=mydata,model=myfullmodWipes2)


# washing hands frequently
myfullmodHands2<- glm(leavehomeact___6 ~ mydata$Classification + mydata$sexf + mydata$agegroup + mydata$educf + mydata$hhincomef + mydata$childrenf + mydata$depression_dichot + mydata$comorbidcatf2, 
                     data = mydata,
                     family = "binomial")
summary(myfullmodHands2)
##multicollinearity##
vif(myfullmodHands2) 
or_glm(data=mydata,model=myfullmodHands2)
