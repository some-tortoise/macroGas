##########
###Math###
##########


#using my trimmed date from Trimming.R
#I don't know compsci well enough to write code to bring this in yet
station1_slug <- trimmed_station1_slug

station1_slug <- station1_slug %>%
  mutate(NaCl_Conc = NA) %>%
  relocate(NaCl_Conc, .after = Low_Range)
station1_slug <- station1_slug %>%
  mutate(Area = NA) %>%
  relocate(Area, .after = NaCl_Conc)

background_cond <- station1_slug$Low_Range[1] #this is a value that I want inputtable on Shiny

station1_slug <- station1_slug %>%
  mutate(NaCl_Conc = (Low_Range - background_cond) * 0.00047) %>%
  mutate(Area = NaCl_Conc * 5)

Area <- sum(station1_slug$Area)
Mass_NaCl <- 1069.66
Discharge <- Mass_NaCl/Area
print(Discharge)
