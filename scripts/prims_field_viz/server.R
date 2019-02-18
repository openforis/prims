####################################################################################
####### PRIMS point 
####### SEPAL shiny application
####### FAO Open Foris SEPAL project
####### remi.dannunzio@fao.org
####################################################################################

####################################################################################
# FAO declines all responsibility for errors or deficiencies in the database or
# software or in the documentation accompanying it, for program maintenance and
# upgrading as well as for any # damage that may arise from them. FAO also declines
# any responsibility for updating the data and assumes no responsibility for errors
# and omissions in the data provided. Users are, however, kindly asked to report any
# errors or deficiencies in this product to FAO.
####################################################################################

####################################################################################
## Last update: 2019/02/19
## prims / server
####################################################################################


####################################################################################
####### Start Server

shinyServer(function(input, output, session) {
  ####################################################################################
  ##################### Choose language option             ###########################
  ####################################################################################
  output$chosen_language <- renderPrint({
    if (input$language == "English") {
      source("www/scripts/text_english.R",
             local = TRUE,
             encoding = "UTF-8")
      #print("en")
    }
    if (input$language == "Bahasa") {
      source("www/scripts/text_bahasa.R", 
             local = TRUE, 
             encoding = "UTF-8")
      #print("fr")
    }
    
  })
  
  ##################################################################################################################################
  ############### Stop session when browser is exited
  
  session$onSessionEnded(stopApp)
  
  ##################################################################################################################################
  ############### Show progress bar while loading everything
  
  progress <- shiny::Progress$new()
  progress$set(message = "Loading data", value = 0)
  
  ####################################################################################
  ####### Step 0 : read the map file and store filepath    ###########################
  ####################################################################################
  
  ##################################################################################################################################
  ############### Find volumes
  osSystem <- Sys.info()["sysname"]
  
  volumes <- list()
  media <- list.files("/media", full.names = T)
  names(media) = basename(media)
  volumes <- c(media)
  
  volumes <- c('Home' = Sys.getenv("HOME"),
               volumes)
  
  my_zip_tools <- Sys.getenv("R_ZIPCMD", "zip")
  
  
  ##################################################################################################################################
  ## Allow to download test data
  output$dynUI_download_test <- renderPrint({
    req(input$download_test_button)
    
    dir.create(file.path("~", "prims_data_test"),showWarnings = F)
    
    withProgress(message = paste0('Downloading data in ', dirname("~/prims_data_test/")),
                 value = 0,
                 {
                   system("wget -O ~/prims_data_test/prims_gwl_example.csv  https://github.com/openforis/data_test/raw/master/prims_example.csv")
                   
                 })
    
    list.files("~/prims_data_test/")
  })
  
  
  ##################################################################################################################################
  ############### Select Forest-Non Forest mask
  shinyFileChoose(
    input,
    'input_file',
    filetype = "csv",
    roots = volumes,
    session = session,
    restrictions = system.file(package = 'base')
  )
  
  ################################# File path
  file_path <- reactive({
    #validate(need(input$input_file, "Missing input: Please select the file"))
    req(input$input_file)
    df <- parseFilePaths(volumes, input$input_file)
    file_path <- as.character(df[, "datapath"])
    
  })
  
  ################################# Display the file path
  output$filepath <- renderPrint({
    #validate(need(input$input_file, "Missing input: Please select the file"))
    
    df <- parseFilePaths(volumes, input$input_file)
    file_path <- as.character(df[, "datapath"])
    nofile <- as.character("No file selected")
    if (is.null(file_path)) {
      cat(nofile)
    } else{
      cat(file_path)
    }
  })
  
  ################################# File directory
  data_dir <- reactive({
    req(input$input_file)
    file_path <- file_path()
    paste0(dirname(file_path),"/")
  })
  
  ##################################################################################################################################
  ############### Parameters title as a reactive
  parameters <- reactive({
    req(input$input_file)
    
    # mspa1 <- as.numeric(input$option_FGconn)
    # mspa2 <- as.numeric(input$option_EdgeWidth)
    # mspa3 <- as.numeric(input$option_Transition)
    # mspa4 <- as.numeric(input$option_Intext)
    # mspa5 <- as.numeric(input$option_dostats)
    # 
    # paste(mspa1,mspa2,mspa3,mspa4,mspa5,sep=" ")
    
  })
  
  # ############### Graphic options as a reactive
  # options <- reactive({
  #   req(input$input_file)
  #   
  #   input$option_graph_type
  #   
  # })
  
  ##################################################################################################################################
  ############### Insert the start button
  output$StartButton <- renderUI({
    #validate(need(input$input_file, "Missing input: select a point file"))
    actionButton('StartButton', textOutput('start_button'))
  })
  
  
  ##################################################################################################################################
  ############### Run 
  prims_res <- eventReactive(input$StartButton,
                             {
                               req(input$input_file)
                               req(input$StartButton)
                               
                               file_path   <- file_path()
                               
                               data <- read.csv(file_path)
                               
                               data <- data[which(data$GWL > -2), ]
                               
                             })
  
  
  
  ############### Display the results as map
  output$display_res <- renderPlot({
    req(prims_res())
    print('Check: Display the map')
    
    data <- prims_res()
    
    rate  <- 10
    my_frequency <- 365*24*60/rate
    
    print(rate)
    
    gwlts  <- ts(data$GWL, frequency=my_frequency,start=c(2017,10))
    smts   <- ts(data$SOILMOISTURE, frequency=my_frequency, start=c(2017,10))
    raints <- ts(data$RAIN, frequency=my_frequency, start=c(2017,10))
    
    graph_type <- input$option_graph_type
    
    if(graph_type == "Color overlap"){
      ts.plot((raints*10), (gwlts*100), smts, gpars = list(col = c("grey", "red", "blue"), ylim=c(-200,200)))}
    else{
      if(graph_type == "BW separated"){
        plot(cbind(raints, gwlts), yax.flip = TRUE)
      }
    }
    
  })
  
  ##################################################################################################################################
  ############### Display parameters
  output$parameterSummary <- renderText({
    req(input$input_file)
    #print(paste0("Parameters are : ",parameters()))
  })
  
  ##################################################################################################################################
  ############### Display time
  output$message <- renderTable({
    req(prims_res())
    
    data <- prims_res()
    
    head(data)
  })
  
  ##################################################################################################################################
  ############### Turn off progress bar
  
  progress$close()
  ################## Stop the shiny server
  ####################################################################################
  
})
