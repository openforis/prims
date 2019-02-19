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
    validate(need(input$input_file, ""))
    
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
  ############### READ THE DATA
  prims_data <- eventReactive(input$StartButton,
                             {
                               req(input$input_file)
                               req(input$StartButton)
                               
                               file_path   <- file_path()
                               
                               data <- read.csv(file_path)
                               
                               data <- data[which(data$GWL > -2), ]
                               
                             })
  
  ##################################################################################################################################
  ############### DAILY PRECIPITATIONS
  daily_sum_precip <- eventReactive(input$StartButton,
                                   {
                                     req(input$input_file)
                                     req(input$StartButton)
                                     req(prims_data())
                                     
                                     data <- prims_data()
                                     
                                     data %>%
                                       mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
                                       group_by(day) %>% # group by the day column
                                       summarise(total_precip=sum(RAIN)) %>%  # calculate the SUM of all precipitation that occurred on each day
                                       na.omit()
                                   })
  
  ##################################################################################################################################
  ############### DAILY GWL                                 
  daily_avg_gwl <- eventReactive(input$StartButton,
                                 {
                                   req(input$input_file)
                                   req(input$StartButton)
                                   req(prims_data())
                                   
                                   data <- prims_data()
                                   
                                   data %>%
                                     mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
                                     group_by(day) %>% # group by the day column
                                     summarise(avg_gwl=mean(GWL)) %>%  # calculate the AVERAGE of GWL
                                     na.omit()
                                 })
  
  ##################################################################################################################################
  ############### DAILY SOIL MOISTURE
  
  daily_avg_sm <- eventReactive(input$StartButton,
                                {
                                  req(input$input_file)
                                  req(input$StartButton)
                                  req(prims_data())
                                  
                                  data <- prims_data()
                                  
                                  data %>%
                                    mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
                                    group_by(day) %>% # group by the day column
                                    summarise(avg_sm=mean(SOILMOISTURE)) %>%  # calculate the AVERAGE OF SOILMOISTURE
                                    na.omit()
                                })
  
  ##################################################################################################################################
  ############### WEEKLY PRECIPITATIONS
  weekly_sum_precip <- eventReactive(input$StartButton,
                                    {
                                      req(input$input_file)
                                      req(input$StartButton)
                                      req(prims_data())
                                      
                                      data <- prims_data()
                                      
                                      data %>%
                                        mutate(week = format(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"),"%W")) %>%
                                        group_by(week) %>% # group by the day column
                                        summarise(total_precip=sum(RAIN)) %>%  # calculate the SUM of all precipitation that occurred on each day
                                        na.omit()
                                    })
  
  ##################################################################################################################################
  ############### DAILY GWL                                 
  weekly_avg_gwl <- eventReactive(input$StartButton,
                                 {
                                   req(input$input_file)
                                   req(input$StartButton)
                                   req(prims_data())
                                   
                                   data <- prims_data()
                                   
                                   data %>%
                                     mutate(week = format(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"),"%W")) %>%
                                     group_by(week) %>% # group by the day column
                                     summarise(avg_gwl=mean(GWL)) %>%  # calculate the AVERAGE of GWL
                                     na.omit()
                                 })
  
  ##################################################################################################################################
  ############### DAILY SOIL MOISTURE
  
  weekly_avg_sm <- eventReactive(input$StartButton,
                                {
                                  req(input$input_file)
                                  req(input$StartButton)
                                  req(prims_data())
                                  
                                  data <- prims_data()
                                  
                                  data %>%
                                    mutate(week = format(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"),"%W")) %>%
                                    group_by(week) %>% # group by the day column
                                    summarise(avg_sm=mean(SOILMOISTURE)) %>%  # calculate the AVERAGE OF SOILMOISTURE
                                    na.omit()
                                })
  
  ##################################################################################################################################
  ############### MONTHLY PRECIPITATIONS
  monthly_sum_precip <- eventReactive(input$StartButton,
                                    {
                                      req(input$input_file)
                                      req(input$StartButton)
                                      req(prims_data())
                                      
                                      data <- prims_data()
                                      
                                      data %>%
                                        mutate(month = month(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"))) %>%
                                        group_by(month) %>% # group by the day column
                                        summarise(total_precip=sum(RAIN)) %>%  # calculate the SUM of all precipitation that occurred on each day
                                        na.omit()
                                    })
  
  ##################################################################################################################################
  ############### MONTHLY GWL                                 
  monthly_avg_gwl <- eventReactive(input$StartButton,
                                 {
                                   req(input$input_file)
                                   req(input$StartButton)
                                   req(prims_data())
                                   
                                   data <- prims_data()
                                   
                                   data %>%
                                     mutate(month = month(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"))) %>%
                                     group_by(month) %>% # group by the day column
                                     summarise(avg_gwl=mean(GWL)) %>%  # calculate the AVERAGE of GWL
                                     na.omit()
                                 })
  
  ##################################################################################################################################
  ############### MONTHLY SOIL MOISTURE
  
  monthly_avg_sm <- eventReactive(input$StartButton,
                                {
                                  req(input$input_file)
                                  req(input$StartButton)
                                  req(prims_data())
                                  
                                  data <- prims_data()
                                  
                                  data %>%
                                    mutate(month = month(as.Date(WAKTU, format = "%m/%d/%Y %H:%M"))) %>%
                                    group_by(month) %>% # group by the day column
                                    summarise(avg_sm=mean(SOILMOISTURE)) %>%  # calculate the AVERAGE OF SOILMOISTURE
                                    na.omit()
                                })
  
  ############### Display the results as map
  output$display_res <- renderPlot({
    req(input$input_file)
    req(input$StartButton)
    req(prims_data())
    
    print('Check: Display the map')
    
    data <- prims_data()
    
    daily_avg_gwl    <- daily_avg_gwl()
    daily_avg_sm     <- daily_avg_sm()
    daily_sum_precip <- daily_sum_precip() 
    
    weekly_avg_gwl    <- weekly_avg_gwl()
    weekly_avg_sm     <- weekly_avg_sm()
    weekly_sum_precip <- weekly_sum_precip() 
    
    monthly_avg_gwl    <- monthly_avg_gwl()
    monthly_avg_sm     <- monthly_avg_sm()
    monthly_sum_precip <- monthly_sum_precip() 
    
    if(input$option_frequency == "10 minutes"){
      
      gwlts  <- ts(data$GWL, frequency=52650,start=c(2017,10))
      smts   <- ts(data$SOILMOISTURE, frequency=52650, start=c(2017,10))
      raints <- ts(data$RAIN, frequency=52650, start=c(2017,10))
      }
    if(input$option_frequency == "Daily"){
      
      gwlts  <- ts(daily_avg_gwl$avg_gwl, frequency=365, start=c(2017,1))
      smts   <- ts(daily_avg_sm$avg_sm, frequency=365, start=c(2017,1))
      raints <- ts(daily_sum_precip$total_precip, frequency=365, start=c(2017,1))
    }
    if(input$option_frequency == "Weekly"){
      
      gwlts  <- ts(weekly_avg_gwl$avg_gwl, frequency=52, start=c(2017,1))
      smts   <- ts(weekly_avg_sm$avg_sm, frequency=52, start=c(2017,1))
      raints <- ts(weekly_sum_precip$total_precip, frequency=52, start=c(2017,1))
    }
    if(input$option_frequency == "Monthly"){
      
      gwlts  <- ts(monthly_avg_gwl$avg_gwl, frequency=12, start=c(2017,1))
      smts   <- ts(monthly_avg_sm$avg_sm, frequency=12, start=c(2017,1))
      raints <- ts(monthly_sum_precip$total_precip, frequency=12, start=c(2017,1))
      }

    graph_type <- input$option_graph_type
    
    if(graph_type == "Color overlap"){
      
      ts.plot((raints*max(smts)/max(raints)), (gwlts*max(smts)/max(gwlts)/20), smts, gpars = list(col = c("grey", "red", "blue"), ylim=c(-max(smts),max(smts))))
      }
    if(graph_type == "BW separated"){
      plot(cbind(raints, gwlts), yax.flip = TRUE)
      }
    if(graph_type == "Cross-correlation"){
      ccf(raints, gwlts, ylab = "Cross-correlation")
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
    req(prims_data())
    
    data <- prims_data()
    
    head(data)
  })
  
  ##################################################################################################################################
  ############### Turn off progress bar
  
  progress$close()
  ################## Stop the shiny server
  ####################################################################################
  
})
