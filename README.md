# Follow below steps to make your r sctipts portable and reusable
# Execution of R script using command line is required in order to proceed

**Step 1**: 
Clone this repo in **C:/R - Projects/** directory using following commands on command line
```

git clone '<repo url>'

```

**Step 2**: 
Edit user name in the second row of user_details.csv

```

user
server # edit this with your name as mentioned in google sheet

```

**Step 3**: 
Open `R - Projects.Rproj` in Rstudio

**Step 4**: 
create "C:/R - Projects/credentials/gmail" directoy on your system

**Step 5**: 
Edit user email in download_project_master.R

```

path_proj <- "C:/R - Projects"

# replace email id below with your email and execute
googlesheets4::gs4_auth(email = "archana.pandita@vmart.co.in", cache = file.path(path_proj, "credentials", "gmail"))

```

**Step 6**: 
Exeute above lines it will open browser to authenticate in order to access your email and save a token file in your system


**Step 7**: 
Add following lines at start of each script to make them directory independent

```

source("C:/R - Projects/library.R")
path_proj <- GET_PROJECT_DIR(proj_id = "pid_47")

```

and change project id as per your project

project paths will be fetched from following google sheets:
https://docs.google.com/spreadsheets/d/1q8sSnPffgVPWFSsV7GqgRO5EAGHmIgq2fTUxQFF1Mz8/edit#gid=44926186
