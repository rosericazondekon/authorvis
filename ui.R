#-------------------------------------------------------------------------
#  Roseric Azondekon,
#  February 20th, 2018
#  Milwaukee, WI, USA
#-------------------------------------------------------------------------

library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(igraph)

#Load each network
malnet<-get(load("./data/malnet.rda"))
hivnet<-get(load("./data/hivnet.rda"))
tbnet<-get(load("./data/tbnet.rda"))

#create a list containing all networks
allNet <- list()
allNet[["malnet.rda"]]<-malnet
allNet[["hivnet.rda"]]<-hivnet
allNet[["tbnet.rda"]]<-tbnet

#Get authors info...
##Names
m_authors<-V(malnet)$name
h_authors<-V(hivnet)$name
t_authors<-V(tbnet)$name
##Years
m_years<-unique(E(malnet)$year)
h_years<-unique(E(hivnet)$year)
t_years<-unique(E(tbnet)$year)

tags$script(src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML")

#Dashboard Menu
dashboard <- dashboardHeader(title = "AuthorVis")

#sidebar Menu
sidebar <- dashboardSidebar(
  hr(),
  sidebarMenu(id="tabs",
              menuItem("Explore Network", tabName="explore", icon=icon("search"), selected=TRUE),
              menuItem("Prediction", tabName = "prediction", icon=icon("lightbulb-o")),
              menuItem("Codes",  icon = icon("code"),
                       menuSubItem("global.R", tabName = "global", icon = icon("file-code-o")),
                       menuSubItem("ui.R", tabName = "ui", icon = icon("file-code-o")),
                       menuSubItem("server.R", tabName = "server", icon = icon("file-code-o")),
                       menuSubItem("Git Repository", tabName = "git", icon = icon("github"))
              ),
              menuItem("ReadMe", tabName = "readme", icon=icon("mortar-board")),
              menuItem("About", tabName = "about", icon = icon("question"))
  )
)

#Building Dashboard Body
##Explore page...
###Network selection input
netSelect <- selectInput("netw", 
                         label = h3("Select a network:"),
                         choices = list("Malaria network" = "malnet.rda", "HIV/AIDS network" = "hivnet.rda", 
                                        "Tuberculosis network" = "tbnet.rda"), 
                         selected = "malnet.rda"
)

##Conditional panel if malaria is selected
mpanel <- conditionalPanel(
  condition="input.netw == 'malnet.rda'",
  box(width=NULL,
      selectizeInput("mauthor", "Search authors:", m_authors,
                     selected = NULL, multiple = T,options = list(maxOptions = 5)),
      sliderInput("myear", "Define a time period:",min = min(m_years), max = max(m_years),sep = "", value = c(min(m_years),max(m_years)),step = 1)
  )
)

##Conditional panel if hiv/aids is selected
hpanel <- conditionalPanel(
  condition="input.netw == 'hivnet.rda'",
  box(width=NULL,
      selectizeInput("hauthor", "Search authors:", h_authors,
                     selected = NULL, multiple = T,options = list(maxOptions = 5)),
      sliderInput("hyear", "Define a time period:",min = min(h_years), max = max(h_years),sep = "", value = c(min(h_years),max(h_years)),step = 1)
  )
)

##Conditional panel if tb is selected
tpanel <- conditionalPanel(
  condition="input.netw == 'tbnet.rda'",
  box(width=NULL,
      selectizeInput("tauthor", "Search authors:", 
                     t_authors,selected = NULL, multiple = T,options = list(maxOptions = 5)),
      sliderInput("tyear", "Define a time period:",min = min(t_years), max = max(t_years),sep = "", value = c(min(t_years),max(t_years)),step = 1)
  )
)
##Assembling explore page

explore <- tabItem(
  tabName = "explore",
  h2("Explore Co-authorship Network"),
  netSelect,mpanel,hpanel,tpanel,br(),verbatimTextOutput("nText"),
  withSpinner(uiOutput("visLink"),size=1,proxy.height=200,type=7),
  br(),actionButton("query","Query Network!")
)

############################################################################################################
############################################################################################################

##Prediction page
###Network selection input
netSelection <- selectInput("netw2", 
                         label = h3("Select a network:"),
                         choices = list("Malaria network" = "malnet", "HIV/AIDS network" = "hivnet", 
                                        "Tuberculosis network" = "tbnet"), 
                         selected = "malnet"
)

##Conditional panel if malaria is selected
malpanel <- conditionalPanel(
  condition="input.netw2 == 'malnet'",
  box(width=NULL,
      selectizeInput("m1author", "Select first author:", m_authors,
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      selectizeInput("m2author", "Select second author:", rev(m_authors),
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      radioButtons("mmodel", label = h3("Select a model"),
                   choices = list("ERGM model" = "malergm", "Temporal ERGM model" = "maltergm"), 
                   selected = "malergm")
  )
)

##Conditional panel if hiv/aids is selected
hivpanel <- conditionalPanel(
  condition="input.netw2 == 'hivnet'",
  box(width=NULL,
      selectizeInput("h1author", "Select first author:", h_authors,
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      selectizeInput("h2author", "Select second author:", rev(h_authors),
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      radioButtons("hmodel", label = h3("Select a model"),
                   choices = list("ERGM model" = "hivergm", "Temporal ERGM model" = "hivtergm"), 
                   selected = "hivergm")
  )
)

##Conditional panel if tb is selected
tbpanel <- conditionalPanel(
  condition="input.netw2 == 'tbnet'",
  box(width=NULL,
      selectizeInput("t1author", "Select first author:", t_authors,
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      selectizeInput("t2author", "Select second author:", rev(t_authors),
                     selected = NULL, multiple = F,options = list(maxOptions = 5)),
      radioButtons("tmodel", label = h3("Select a model"),
                   choices = list("ERGM model" = "tbergm", "Temporal ERGM model" = "tbtergm"), 
                   selected = "tbergm")
  )
)

prediction <- tabItem(
  tabName = "prediction",
  h2("Model Prediction"),
  netSelection,malpanel,hivpanel,tbpanel,br(),
  withSpinner(uiOutput("predValue"),size=1,proxy.height=200,type=1),
  br(),actionButton("predict","Predict Tie probability!")
)

############################################################################################################
############################################################################################################

##UI page
uipage <- tabItem(
  tabName = "ui",
  h2("R script: User Interface"),
  box( width = NULL, status = "primary", solidHeader = TRUE, title="ui.R",
       downloadButton('downloadData2', 'Download'),
       br(),br(),
       pre(includeText("ui.R"))
  )
)

############################################################################################################
############################################################################################################

##Git page...
gitpage <- tabItem(
  tabName = "git",
  h2("Check my git Repo for HTML and Javascript codes!"),
  includeMarkdown("git.Rmd")
)

############################################################################################################
############################################################################################################

##Server page
serverpage <- tabItem(
  tabName = "server",
  h2("R script: Server"),
  box(width = NULL, status = "primary", solidHeader = TRUE, title="server.R",
      downloadButton('downloadData3', 'Download'),
      br(),br(),
      pre(includeText("server.R"))
  )
)

############################################################################################################
############################################################################################################


##Global.R page
globalpage <- tabItem(
  tabName = "global",
  h2("R script: Global Environment"),
  box(width = NULL, status = "primary", solidHeader = TRUE, title="global.R",
      downloadButton('downloadData4', 'Download'),
      br(),br(),
      pre(includeText("global.R"))
  )
)

############################################################################################################
############################################################################################################

##Readme page...
readme <- tabItem(tabName = "readme",
                  h2("Readme"),
                  withMathJax(includeMarkdown("readme.Rmd"))
)

############################################################################################################
############################################################################################################

##About page...
about <- tabItem(
  tabName = "about",
  h2("About this project!"),
  includeMarkdown("about.Rmd")
)

############################################################################################################
############################################################################################################

#Assembling Dashboard menu...
menu <- tabItems(explore,prediction,globalpage,uipage,serverpage,gitpage,readme,about)

#Display body
body <- dashboardBody(menu)

#Building Dashboard...
dashboardPage(dashboard,sidebar,body)