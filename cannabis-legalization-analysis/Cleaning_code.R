library(readxl)

fisc <- read_excel("fisc.xlsx", sheet = "Data")
legal <- read_excel("policies.xlsx")

#########################################
#                  Fisc                 #   
#########################################

library(dplyr)
library(stringr)

fisc <- fisc %>%
  mutate(state_code = str_split(city_name, ":", simplify = TRUE)[,1])
df <- fisc[, c("year",
             "city_name",
             "state_code",
             "city_types",
             "id2_city",
             "city_population",
             "rev_general_city",
             "police",
             "corrections",
             "spending_general_city")]
min(df$year)

df <- df %>%
  filter(year >= 1994 & year <= 2022)

df <- df %>%
  mutate(
    police_share = police / spending_general_city,
    correction_share = corrections / spending_general_city
  )

View(df)
#########################################
#                  legal                #   
#########################################

df2 <- legal %>%
  filter(Year >= 1994 & Year <= 2022)

df2 <- df2[, c('State Ab','Year','PermissiveImp')]

df2 <- df2 %>%
  rename(
    state_code = `State Ab`,
    year = Year,
    permissive = PermissiveImp,
  )

max(df2$permissive)

View(df2)


####################### 
#       MERGING       #
#######################

#creating a vector with all states 
city_code <- unique(df2$state_code)
print(city_code)


#Only keeping cities in these states
df <- df[df$state_code %in% city_code, ]

 
#Merging
data_clean <- df %>%
  left_join(
    df2 %>% 
      select(state_code, year, permissive),
    by = c("state_code", "year")
  )


#creating binary treatment variable
data_clean$bi_permissive_RCL <- ifelse(data_clean$permissive >= 7, 1, 0)


View(data_clean)
library(writexl)

write_xlsx(df, "data_clean.xlsx")

#head()