#-------------------------------------------------------------------------
#  Roseric Azondekon,
#  February 20th, 2018
#  Milwaukee, WI, USA
#-------------------------------------------------------------------------

#function tojson
graphToJSON <- function(graph,tmp){
  #creation de la partie qui renseigne les "nodes"
  temp<-cbind(as.numeric(V(graph)$id),V(graph)$name,V(graph)$affil,V(graph)$place,
              V(graph)$country,as.numeric(V(graph)$numPub),as.numeric(V(graph)$timesCited))
  
  colnames(temp)<-c("id","name","affil","place","country","numPub","timesCited")
  js1<-toJSON(temp)
  
  #creation de la partie qui renseigne les "liens"
  write.graph(graph,"edgelist.csv",format="edgelist")
  edges<-read.csv("edgelist.csv",sep=" ",header=F)
  file.remove("edgelist.csv")
  
  #for aggregated graph
  title<-numeric(length(E(graph)))
  journal<-numeric(length(E(graph)))
  subject<-numeric(length(E(graph)))
  doi<-numeric(length(E(graph)))
  wosid<-numeric(length(E(graph)))
  year<-numeric(length(E(graph)))
  for(i in 1:length(E(graph))){
    title[i]<-paste(unlist(E(graph)$title[i]), collapse='|||')
    journal[i]<-paste(unlist(E(graph)$journal[i]), collapse='|||')
    subject[i]<-paste(unlist(E(graph)$subject[i]), collapse='|||')
    doi[i]<-paste(unlist(E(graph)$doi[i]), collapse='|||')
    wosid[i]<-paste(unlist(E(graph)$wosid[i]), collapse='|||')
    year[i]<-paste(unlist(E(graph)$year[i]), collapse='|||')
  }
  edges<-cbind(edges,E(graph)$weight,title,journal,subject,doi,wosid,E(graph)$timesCited,
               year)
  
  colnames(edges)<-c("source","target","weight","title","journal","subject",
                     "doi","wosid","timesCited","year")
  edges$source<-as.numeric(edges$source)
  edges$target<-as.numeric(edges$target)
  edges<-as.matrix(edges)
  js2<-toJSON(edges)
  #concatenation des deux parties
  reseau<-paste('{"nodes":',js1,',"links":',js2,'}',sep="")
  write(reseau,file=paste0("./",tmp,"/graph.json"))
  system(paste0('python ./script/cleanJson.py ./',tmp,'/graph.json'), wait = FALSE)
  # file.remove("./visNetwork/graph.json")
}

#
function(input, output, session) {
  a <- Sys.time()
  tmp <- digest::digest(a) #hashed timestamped temporary folder name
  system(paste0("mkdir ",tmp," && cp -r ./visNetwork/. ./",tmp,"/."), wait = FALSE)
  output$nText <- renderText({
    net<-input$netw
    if(net == "malnet.rda"){
      year <- input$myear
      author <- input$mauthor
      # paste("Year:",year[1],"-",year[2])
    } else if(net == "hivnet.rda"){
      year <- input$hyear
      author <- input$hauthor
      # paste("Year:",year[1],"-",year[2])
    } else {
      year <- input$tyear
      author <- input$tauthor
      # paste("Year:",year[1],"-",year[2])
    }
    # author<-as.vector(author)
    if(year[1] == year[2]){
      G <- subgraph.edges(allNet[[net]],which(E(allNet[[net]])$year==year[1]))
    } else{
      G <- subgraph.edges(allNet[[net]],which(E(allNet[[net]])$year>=year[1] & E(allNet[[net]])$year<=year[2]))
    }
    g <- simplify(G, 
                  edge.attr.comb = list(
                    weight="sum",timesCited="sum",
                    numPub="sum",key="concat",subject="concat",
                    year="concat",wosid="concat",journal="concat",
                    title="concat",doi="concat"))
    
    if(length(author)!=0){
      neighb <- c(author,unique(V(g)$name[as.numeric(neighbors(graph = g,v=author))]))
      g <- induced_subgraph(g,neighb)
    }
    N <- length(V(g))
    E <- length(E(g))
    # paste(length(author))
    paste("The current query will return:",N,"authors and",E,"collaboration ties.")
  })
  
  visLink <- eventReactive(input$query, {
    net<-input$netw
    if(net == "malnet.rda"){
      year <- input$myear
      author <- input$mauthor
      # paste("Year:",year[1],"-",year[2])
    } else if(net == "hivnet.rda"){
      year <- input$hyear
      author <- input$hauthor
      # paste("Year:",year[1],"-",year[2])
    } else {
      year <- input$tyear
      author <- input$tauthor
      # paste("Year:",year[1],"-",year[2])
    }
    # author<-as.vector(author)
    G <- subgraph.edges(allNet[[net]],which(E(allNet[[net]])$year>=year[1] & E(allNet[[net]])$year<=year[2]))
    g <- simplify(G, 
                  edge.attr.comb = list(
                    weight="sum",timesCited="sum",
                    numPub="sum",key="concat",subject="concat",
                    year="concat",wosid="concat",journal="concat",
                    title="concat",doi="concat"))
    V(g)$id<-0:length(V(g))
    if(length(author)!=0){
      neighb <- c(author,unique(V(g)$name[as.numeric(neighbors(graph = g,v=author))]))
      g <- induced_subgraph(g,neighb)
      V(g)$id<-0:length(V(g))
    }
    graphToJSON(g,tmp)
    system("killall node", wait = FALSE)
    ip <- get_ip()
    # port <- round(runif(1,10000,20000))
    port<-8081
    # cmd <- paste0("cd ./visNetwork && Rscript -e 'servr::httd()' -b -p",port)
    cmd <- paste0("cd ./",tmp," && http-server -p ", port," -o")
    system(cmd, wait = FALSE)
    url <- a("Click me to visualize your queried Network!", href=paste0("http://",ip,":",port), 
             # onClick='javascript:window.location.reload(true);javascript:opener.location.getElementById("refresh")',
             target="_blank")
    url
  })
  
  output$visLink <- renderUI({
    url <- visLink()
    tagList("URL link:", url)
  })
  
  predValue <- eventReactive(input$predict, {
    net2 <- input$netw2
    #pred <- 0
    if(net2 == "malnet"){
      auth1 <- which(V(malnet)$name==input$m1author)
      auth2 <- which(V(malnet)$name==input$m2author)
      if(input$mmodel == "malergm"){
        pred <- interpret(malergm,type = "tie", i = auth1, j = auth2)
      }else if(input$mmodel == "maltergm"){
        pred <- mean(interpret(maltergm, type = "tie", i = auth1, j = auth2))
      }
      auths <- paste(input$m1author,"and",input$m2author)
    }else if(net2 == "hivnet"){
      auth1 <- which(V(hivnet)$name==input$h1author)
      auth2 <- which(V(hivnet)$name==input$h2author)
      if(input$hmodel == "hivergm"){
        pred <- interpret(hivergm, type = "tie", i = auth1, j = auth2)
      }else if(input$hmodel == "hivtergm"){
        pred <- mean(interpret(hivtergm, type = "tie", i = auth1, j = auth2))
      }
      auths <- paste(input$h1author,"and",input$h2author)
    } else if(net2 == "tbnet"){
      auth1 <- which(V(tbnet)$name==input$t1author)
      auth2 <- which(V(tbnet)$name==input$t2author)
      if(input$tmodel == "tbergm"){
        pred <- interpret(tbergm, type = "tie", i = auth1, j = auth2)
      }else if(input$tmodel == "tbtergm"){
        pred <- mean(interpret(tbtergm, type = "tie", i = auth1, j = auth2))
      }
      auths <- paste(input$t1author,"and",input$t2author)
    }
    
    msg <- paste0("The probability of future collaboration between ",auths,
                  " is estimated at ",round(pred*100,2),"%")
    msg
  })
  
  output$predValue <- renderUI({
    predMessage <- predValue()
    tagList(predMessage)
  })
  
  session$onSessionEnded(function() {
    b <- Sys.time()
    endMsg <- paste("The session opening at", a,"has ended at",b)
    print(endMsg)
    system(paste0("rm -r ",tmp)) # Delete temporary session folder
    system("killall node", wait = FALSE) # kill all http server
  })
}

