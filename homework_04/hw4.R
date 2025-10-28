# install and update json package for R analysis

install.packages('rjson')
update.packages('rjson')
library("rjson")

Rich_Famous <- fromJSON(file = "rich_famous.json")

# 1) List names
# loop through the objects, output the value of the 'name' attribute

for (smth in Rich_Famous) {
    print(noquote(smth$name))
}

# 2) List names that repeat more than once

Names <- list() # makes empty list

for (smth in Rich_Famous) {
  
    if (!(smth$name %in% Names))  { # name not in list => first time it's encountered
        Names <- c(Names, smth$name)  # add name to list if first time
    }
  
  else {
    print(noquote(smth$name))  # if the name is already in the list, it's repeating => display it
  }
  
}

# 3) List names of all Romans

for (smth in Rich_Famous) {
  
    if (grepl("Roman", smth$occupation$name))   # TRUE if "Roman" is a substring of occupation name
    {print (noquote(smth$name))}
}

# 4) List names and contacts in DataFrame

DFLength <- length(Rich_Famous) # find out how many rows we need
DFRich <- data.frame(matrix(NA, ncol = 2, nrow = DFLength))  # make empty df with 2 columns and DFLength rows
colnames(DFRich) <- c('Name', 'Contact')
Count <- 1

for (smth in Rich_Famous) {
  
      DFRich$Name[Count] <- smth$name    # on each iteration puts the name and web into the Count-th row.
      DFRich$Contact[Count] <- smth$web
      Count <- Count + 1
}


