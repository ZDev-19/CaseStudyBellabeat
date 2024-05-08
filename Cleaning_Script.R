#Instalacion de librerias
install.packages("tidyverse")
install.packages("here")
install.packages("skimr")
install.packages("janitor")

#Carga de librerias
library("tidyverse")
library("here")
library("skimr")
library("janitor")

#Carga de datos

ruta <- "Raw_data/"

da1 <- read_csv(paste(ruta,"dailyActivity_period1.csv",sep = ""))
da2  <- read_csv(paste(ruta,"dailyActivity_period2.csv",sep = ""))
hs1 <- read_csv(paste(ruta,"heartrate_seconds_period1.csv",sep = ""))
hs2 <- read_csv(paste(ruta,"heartrate_seconds_period2.csv",sep = ""))
hc1 <- read_csv(paste(ruta,"hourlyCalories_period1.csv",sep = ""))
hc2 <- read_csv(paste(ruta,"hourlyCalories_period2.csv",sep = ""))
hi1 <- read_csv(paste(ruta,"hourlyIntensities_period1.csv",sep = ""))
hi2 <- read_csv(paste(ruta,"hourlyIntensities_period1.csv",sep = ""))
hst1 <- read_csv(paste(ruta,"hourlySteps_period1.csv",sep = ""))
hst2 <- read_csv(paste(ruta,"hourlySteps_period2.csv",sep = ""))
mmn1 <- read_csv(paste(ruta,"minute_MET_Narrow_period1.csv",sep = ""))
mmn2 <- read_csv(paste(ruta,"minute_MET_Narrow_period2.csv",sep = ""))
mcn1 <- read_csv(paste(ruta,"minuteCalories_Narrow_period1.csv",sep = ""))
mcn2 <- read_csv(paste(ruta,"minuteCalories_Narrow_period2.csv",sep = ""))
min1 <- read_csv(paste(ruta,"minuteIntensities_Narrow_period1.csv",sep = ""))
min2 <- read_csv(paste(ruta,"minuteIntensities_Narrow_period2.csv",sep = ""))
ms1 <- read_csv(paste(ruta,"minuteSleep_period1.csv",sep = ""))
ms2 <- read_csv(paste(ruta,"minuteSleep_period2.csv",sep = ""))
wl1 <- read_csv(paste(ruta,"weight_Log_Info_period1.csv",sep = ""))
wl2 <- read_csv(paste(ruta,"weight_Log_Info_period2.csv",sep = ""))
mst1 <- read_csv(paste(ruta,"minute_Steps_Narrow_period1.csv",sep = ""))
mst2 <- read_csv(paste(ruta,"minute_Steps_Narrow_period2.csv",sep = ""))

# Union de archivos
dailyActivity <- rbind(da1,da2)
heartrateSeconds <- rbind(hs1,hs2)
hourlyCalories <- rbind(hc1,hc2)
hourlyIntensities <- rbind(hi1,hi2)
hourlySteps <- rbind(hst1,hst2)
minuteMET <- rbind(mmn1,mmn2)
minuteSteps <- rbind(mst1,mst2)
minuteCalories <- rbind(mcn1,mcn2)
minuteIntensities <- rbind(min1,min2)
minuteSleep <- rbind(ms1,ms2)
weightInfo <- rbind(wl1,wl2)

# Analisis exploratorio de archivos

# Conjunto dailyActivity
head(dailyActivity)
View(dailyActivity)

str(dailyActivity)

# Cambio de formato a fecha ActivityDate
dailyActivity$ActivityDate <- as_date(dailyActivity$ActivityDate,format="%m/%d/%Y")
dailyActivity$ActivityDate <- format(dailyActivity$ActivityDate,"%d-%m-%Y")
View(dailyActivity)

sum(is.na(dailyActivity))
sapply(dailyActivity, function(x) sum(is.na(x)))

colnames(dailyActivity)

write.csv(dailyActivity,paste("Data/","DailyActivity.csv",sep = ""),row.names=FALSE)


#Conjunto de datos HeartrateSeconds
head(heartrateSeconds)
View(heartrateSeconds)

str(heartrateSeconds)

#Cambio de formato a feche Time
heartrateSeconds$Time <- strptime(heartrateSeconds$Time,"%m/%d/%Y %I:%M:%S %p")
heartrateSeconds$Time <- format(heartrateSeconds$Time,"%Y-%m-%d %H:%M:%S")
View(heartrateSeconds)

sum(is.na(heartrateSeconds))
sapply(heartrateSeconds, function(x) sum(is.na(x)))

colnames(heartrateSeconds)
names(heartrateSeconds) <- c("Id","Record","Heartrate")

write.csv(heartrateSeconds,paste("Data/","HeartrateSeconds.csv",sep = ""),row.names=FALSE)

#Conjunto de datos HourlyCalories
head(hourlyCalories)
View(hourlyCalories)

str(hourlyCalories)

sum(is.na(hourlyCalories))
sapply(hourlyCalories, function(x) sum(is.na(x)))

hourlyCalories$ActivityHour<- strptime(hourlyCalories$ActivityHour,"%m/%d/%Y %I:%M:%S %p")
hourlyCalories$ActivityHour <- format(hourlyCalories$ActivityHour,"%Y-%m-%d %H:%M:%S")
View(hourlyCalories)

colnames(hourlyCalories)
names(hourlyCalories) <- c("Id","Record","Calories")

write.csv(hourlyCalories,paste("Data/","HourlyCalories.csv",sep = ""),row.names=FALSE)

#Conjunto de datos HourlyIntensities
head(hourlyIntensities)
View(hourlyIntensities)

sum(is.na(hourlyIntensities))
sapply(hourlyIntensities, function(x) sum(is.na(x)))

hourlyIntensities$ActivityHour<- strptime(hourlyIntensities$ActivityHour,"%m/%d/%Y %I:%M:%S %p")
hourlyIntensities$ActivityHour <- format(hourlyIntensities$ActivityHour,"%Y-%m-%d %H:%M:%S")
View(hourlyIntensities)

colnames(hourlyIntensities)
names(hourlyIntensities) <- c("Id","Record","Total Intensity" , "Avg Intensity")

write.csv(hourlyIntensities,paste("Data/","HourlyIntensities.csv",sep = ""),row.names=FALSE)

#Conjunto de datos HourlySteps
head(hourlySteps)
View(hourlySteps)

sum(is.na(hourlySteps))
sapply(hourlySteps, function(x) sum(is.na(x)))

hourlySteps$ActivityHour<- strptime(hourlySteps$ActivityHour,"%m/%d/%Y %I:%M:%S %p")
hourlySteps$ActivityHour <- format(hourlySteps$ActivityHour,"%Y-%m-%d %H:%M:%S")
View(hourlySteps)

colnames(hourlySteps)
names(hourlySteps) <- c("Id","Record","Total Steps")

write.csv(hourlySteps,paste("Data/","HourlySteps.csv",sep = ""),row.names=FALSE)

#Conjunto de datos MinuteMET
head(minuteMET)
View(minuteMET)

sum(is.na(minuteMET))
sapply(minuteMET, function(x) sum(is.na(x)))

minuteMET$ActivityMinute <- strptime(minuteMET$ActivityMinute,"%m/%d/%Y %I:%M:%S %p")
minuteMET$ActivityMinute <- format(minuteMET$ActivityMinute,"%Y-%m-%d %H:%M:%S")
View(minuteMET)

colnames(minuteMET)
names(minuteMET) <- c("Id","Record","METs")

write.csv(minuteMET,paste("Data/","MinuteMET.csv",sep = ""),row.names=FALSE)

#Conjunto de datos MinuteSteps
head(minuteSteps)
View(minuteSteps)

sum(is.na(minuteSteps))
sapply(minuteSteps, function(x) sum(is.na(x)))

minuteSteps$ActivityMinute <- strptime(minuteSteps$ActivityMinute ,"%m/%d/%Y %I:%M:%S %p")
minuteSteps$ActivityMinute <- format(minuteSteps$ActivityMinute,"%Y-%m-%d %H:%M:%S")
View(minuteSteps)

colnames(minuteSteps)
names(minuteSteps) <- c("Id","Record","Steps")

write.csv(minuteSteps,paste("Data/","MinuteSteps.csv",sep = ""),row.names=FALSE)

#Conjunto de datos MinuteCalories
head(minuteCalories)
View(minuteCalories)

sum(is.na(minuteCalories))
sapply(minuteCalories, function(x) sum(is.na(x)))

minuteCalories$ActivityMinute <- strptime(minuteCalories$ActivityMinute ,"%m/%d/%Y %I:%M:%S %p")
minuteCalories$ActivityMinute <- format(minuteCalories$ActivityMinute,"%Y-%m-%d %H:%M:%S")
View(minuteCalories)

colnames(minuteCalories)
names(minuteCalories) <- c("Id","Record","Calories")

write.csv(minuteCalories,paste("Data/","MinuteCalories.csv",sep = ""),row.names=FALSE)

#Conjunto de datos MinuteIntensities
head(minuteIntensities)
View(minuteIntensities)

sum(is.na(minuteIntensities))
sapply(minuteIntensities, function(x) sum(is.na(x)))

minuteIntensities$ActivityMinute <- strptime(minuteIntensities$ActivityMinute ,"%m/%d/%Y %I:%M:%S %p")
minuteIntensities$ActivityMinute <- format(minuteIntensities$ActivityMinute,"%Y-%m-%d %H:%M:%S")
View(minuteIntensities)

colnames(minuteIntensities)
names(minuteIntensities) <- c("Id","Record","Intensity")

write.csv(minuteIntensities,paste("Data/","MinuteIntensities.csv",sep = ""),row.names=FALSE)

#Conjunto de datos MinuteSleep
head(minuteSleep)
View(minuteSleep)

sum(is.na(minuteSleep))
sapply(minuteSleep, function(x) sum(is.na(x)))


minuteSleep$date <- strptime(minuteSleep$date ,"%m/%d/%Y %I:%M:%S %p")
minuteSleep$date <- format(minuteSleep$date,"%Y-%m-%d %H:%M:%S")
View(minuteSleep)

colnames(minuteSleep)
names(minuteSleep) <- c("Id","Record","Value","LogId")

write.csv(minuteSleep,paste("Data/","MinuteSleep.csv",sep = ""),row.names=FALSE)

#Conjunto de datos WeightLog
head(weightInfo)
View(weightInfo)

sum(is.na(weightInfo))
sapply(weightInfo, function(x) sum(is.na(x)))

weightInfo <- select(weightInfo,-Fat, -IsManualReport , -LogId)

weightInfo$Date <- strptime(weightInfo$Date,"%m/%d/%Y %I:%M:%S %p")
weightInfo$Date <- format(weightInfo$Date,"%Y-%m-%d %H:%M:%S")
View(weightInfo)

colnames(weightInfo)
names(weightInfo) <- c("Id","Record","Weight Kg" , "Weight Pounds" , "BMI")

write.csv(weightInfo,paste("Data/","WeightInfo.csv",sep = ""),row.names=FALSE)

