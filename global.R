#-------------------------------------------------------------------------
#  Roseric Azondekon,
#  February 20th, 2018
#  Last Update: July 2nd, 2018
#  Milwaukee, WI, USA
#-------------------------------------------------------------------------

print("Loading global environment...")
library(shiny)
library(igraph)
library(networkD3)
library(RJSONIO)
# library(devtools)
# install_github("gregce/ipify")
library(ipify)
library(servr)
library(ergm)
library(btergm)
library(rmarkdown)

#Start http-server on port 8080
# system("killall node", wait = F) # Run this code to close all other http server instances running
# system('cd ./visNetwork && http-server -p 8080', wait = FALSE)

# Add authors subjects for world cloud...
addAuthSubj<-function(graph){
  all_subj<-c()
  for(v in V(graph)){
    edges<-unlist(incident_edges(graph,v))
    subj<-gsub("'","",gsub("u'","",paste(E(graph)$subject[edges],collapse = ', ')))
    all_subj<-c(all_subj,subj)
  }
  V(graph)$subject<-all_subj
  graph
}

print("Downloading required data files... Please, wait...")

#malnet.rda
if(!file.exists("./data/malnet.rda")){
  print("Downloading malnet.rda... Please, wait...")
  l="https://www.dropbox.com/s/q96jzx4znnd9pe0/malnet.rda?dl=0"
  cmd<- paste("cd ./data && wget -O malnet.rda",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#hivnet.rda
if(!file.exists("./data/hivnet.rda") & !exists("hivnet")){
  print("Downloading hivnet.rda... Please, wait...")
  l="https://www.dropbox.com/s/ma741dycel1v9yo/hivnet.rda?dl=0"
  cmd<- paste("cd ./data && wget -O hivnet.rda",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#tbnet.rda
if(!file.exists("./data/tbnet.rda") & !exists("tbnet")){
  print("Downloading tbnet.rda... Please, wait...")
  l="https://www.dropbox.com/s/9gz2onn4suh5d2a/tbnet.rda?dl=0"
  cmd<- paste("cd ./data && wget -O tbnet.rda",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

############## Downloading ERGM models...
#malergm.rda
if(!file.exists("./data/malergm.rda") & !exists("malergm")){
  print("Downloading malergm.rda... Please, wait...")
  l="https://www.dropbox.com/s/zr605rt12gsgh2w/malergm.rda?dl=0"
  cmd<- paste("cd ./data && wget -O malergm.rda",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#hivergm.rds
if(!file.exists("./data/hivergm.rds") & !exists("hivergm")){
  print("Downloading hivergm.rds... Please, wait...")
  l="https://www.dropbox.com/s/lqj43mrjibv04h8/hivergm.rds?dl=0"
  cmd<- paste("cd ./data && wget -O hivergm.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#tbergm.rds
if(!file.exists("./data/tbergm.rds") & !exists("tbergm")){
  print("Downloading tbergm.rds... Please, wait...")
  l="https://www.dropbox.com/s/brlrh8773ftsul8/tbergm.rds?dl=0"
  cmd<- paste("cd ./data && wget -O tbergm.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}


################ Downloading TERGM models
#maltergm.rds
if(!file.exists("./data/maltergm.rds") & !exists("maltergm")){
  print("Downloading maltergm.rds... Please, wait...")
  l="https://www.dropbox.com/s/mq3rto77kgmdpdi/maltergm.rds?dl=0"
  cmd<- paste("cd ./data && wget -O maltergm.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#hivtergm.rds
if(!file.exists("./data/hivtergm.rds") & !exists("hivtergm")){
  print("Downloading hivtergm.rds... Please, wait...")
  l="https://www.dropbox.com/s/1gqmwbtf0bd6wxc/hivtergm.rds?dl=0"
  cmd<- paste("cd ./data && wget -O hivtergm.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#tbtergm.rds
if(!file.exists("./data/tbtergm.rds") & !exists("tbtergm")){
  print("Downloading tbtergm.rds... Please, wait...")
  l="https://www.dropbox.com/s/d8kdejpwcgygjtu/tbtergm.rds?dl=0"
  cmd<- paste("cd ./data && wget -O tbtergm.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}


################# Downloading temporal data
#listmalnet.rds
if(!file.exists("./data/listmalnet.rds") & !exists("listmalnet")){
  print("Downloading listmalnet.rds... Please, wait...")
  l="https://www.dropbox.com/s/0s9vl9x0eq2z88o/listmalnet.rds?dl=0"
  cmd<- paste("cd ./data && wget -O listmalnet.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#listhivnet.rds
if(!file.exists("./data/listhivnet.rds") & !exists("listhivnet")){
  print("Downloading listhivnet.rds... Please, wait...")
  l="https://www.dropbox.com/s/2f17spsjhzw2uxg/listhivnet.rds?dl=0"
  cmd<- paste("cd ./data && wget -O listhivnet.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

#listtbnet.rds
if(!file.exists("./data/listtbnet.rds") & !exists("listtbnet")){
  print("Downloading listhivnet.rds... Please, wait...")
  l="https://www.dropbox.com/s/kacw7jyaonlximc/listtbnet.rds?dl=0"
  cmd<- paste("cd ./data && wget -O listtbnet.rds",l,"&& cd ..")
  system(cmd, wait = T, intern = T, show.output.on.console = F)
}

print("Loading global variables...")
#Load each network
#Loading data...
if(!exists("malnet")){malnet<-addAuthSubj(get(load("./data/malnet.rda"))})
if(!exists("hivnet")){hivnet<-addAuthSubj(get(load("./data/hivnet.rda"))})
if(!exists("tbnet")){tbnet<-addAuthSubj(get(load("./data/tbnet.rda"))})

#create a list containing all networks
allNet <- list()
allNet[["malnet.rda"]]<-malnet)
allNet[["hivnet.rda"]]<-hivnet)
allNet[["tbnet.rda"]]<-tbnet

#Loading ergm models
print("Loading ergm models...")
if(!exists("malergm")){malergm <- get(load("./data/malergm.rda"));maltergm<-malergm}
if(!exists("hivergm")){hivergm <- readRDS("./data/hivergm.rds")}
if(!exists("tbergm")){tbergm <- readRDS("./data/tbergm.rds")}


#Loading static nets for ergm models
print("Loading ergm graphs...")
#Loading data...
if(!exists("mnet3.simple")){mnet3.simple <- readRDS("./data/mal/mnet3simple.rds")}
if(!exists("hiv.simple")){hiv.simple <- readRDS("./data/hiv/mnet3simple.rds")}
if(!exists("tb.simple")){tb.simple <- readRDS("./data/tb/mnet3simple.rds")}


#Loading tergm models
print("Loading tergm models...")
if(!exists("maltergm")){maltergm <- readRDS("./data/maltergm.rds")}
if(!exists("hivtergm")){hivtergm <- readRDS("./data/hivtergm.rds")}
if(!exists("tbtergm")){tbtergm <- readRDS("./data/tbtergm.rds")}

#Loading temporal net for tergm models
print("Loading tergm graphs...")
#Loading data...
if(!exists("list.malnet")){list.malnet <- readRDS("./data/listmalnet.rds")}
if(!exists("list.hivnet")){list.hivnet <- readRDS("./data/listhivnet.rds")}
if(!exists("list.tbnet")){list.tbnet <- readRDS("./data/listtbnet.rds")}


print("Done!")
