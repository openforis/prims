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
                   system("wget -O ~/prims_data_test/brg12.zip  https://github.com/openforis/data_test/raw/master/brg12.zip")
                   system("unzip -o ~/prims_data_test/brg12.zip  -d ~/prims_data_test/brg12 ")
                   system("rm ~/prims_data_test/brg12.zip")
                   
                 })
    
    list.files("~/prims_data_test/")
  })
  
  
  # ##################################################################################################################################
  # ############### Select Forest-Non Forest mask
  # shinyFileChoose(
  #   input,
  #   'input_file',
  #   filetype = "csv",
  #   roots = volumes,
  #   session = session,
  #   restrictions = system.file(package = 'base')
  # )
  # 
  # ################################# File path
  # file_path <- reactive({
  #   #validate(need(input$input_file, "Missing input: Please select the file"))
  #   req(input$input_file)
  #   df <- parseFilePaths(volumes, input$input_file)
  #   file_path <- as.character(df[, "datapath"])
  #   
  # })

  ##################################################################################################################################
  ############### Select Forest-Non Forest mask
  shinyDirChoose(
    input,
    'input_folder',
    roots = volumes,
    session = session,
    restrictions = system.file(package = 'base')
  )

  ################################# File path
  folder <- reactive({
    validate(need(input$input_folder, "Missing input: Please select the file"))
    req(input$input_folder)
    df <- parseDirPath(volumes, input$input_folder)
    # file_path <- as.character(df[, "datapath"])

  })
  
  ################################# Display tiles inside the DATA_DIR
  output$outdirpath <- renderPrint({
    req(input$input_folder)
    basename(folder())
  })
  
  ################################# Display the file path
  # output$filepath <- renderPrint({
  #   validate(need(input$input_folder, ""))
  #   
  #   df <- parseFilePaths(volumes, input$input_folder)
  #   file_path <- as.character(df[, "datapath"])
  #   nofile <- as.character("No file selected")
  #   if (is.null(file_path)) {
  #     cat(nofile)
  #   } else{
  #     cat(file_path)
  #   }
  # })
  
  # ################################# File directory
  # data_dir <- reactive({
  #   req(input$input_folder)
  #   file_path <- file_path()
  #   paste0(dirname(file_path),"/")
  # })
  
  ##################################################################################################################################
  ############### Parameters title as a reactive
  parameters <- reactive({
    req(input$input_folder)
    
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
                               req(input$input_folder)
                               req(input$StartButton)
                               
                               #file_path   <- file_path()
                               
                               offset        <- read.csv(paste0("www/offset_sesame_20190423.csv"))
                               offset$offset <- gsub(",",".",offset$offset)
                               
                               folder  <- paste0(folder(),"/")
                               print(folder)
                               files   <- list.files(folder)
                               
                               code    <- gsub(pattern = " ",replacement = "",basename(folder))
                               code    <- gsub(pattern="_",replacement = "",code)
                               code
                               the_off <- offset[offset$KODE == code,]$offset
                               
                               df <- NA
                               
                               for(file in files){
                                 df <- append(df,readLines(paste0(folder,file)))
                               }
                               
                               df0      <- df[!grepl(pattern = "TX=",df)]
                               df0      <- df0[!grepl(pattern = "TEST",df0)]
                               df0      <- df0[!grepl(pattern = "MEM",df0)]
                               df0      <- df0[-1]
                               d0 <- data.frame(str_split_fixed(df0,",",12))
                               
                               names(d0) <- c("date_time","data_id","voltage","raw_wl","wl",
                                              "temp1","temp2","raw_data_temp1","raw_data_temp2",
                                              "pulse_count","time_interval","soil_moisture")
                               head(d0)
                               
                               for(col in 2:ncol(d0)){
                                 d0[,col] <- as.numeric(d0[,col])
                               }
                               
                               d0$WAKTU          <- as.Date(paste0("20",d0$date_time,format="%Y/%m/%d %H:%M"))
                               d0$GWL            <- d0$wl - as.numeric(the_off)
                               d0$RAIN           <- d0$pulse_count / 2 
                               d0$V              <- d0$soil_moisture/2000
                               d0$SOILMOISTURE   <- (-0.039+1.8753*(d0$V)-4.0596*(d0$V)^2+6.3711*(d0$V)^3-4.7477*(d0$V)^4+1.3911*(d0$V)^5)*100

                               data <- d0
                               data <- data[which(data$GWL > -2), ]
                               
                             })
  
  ##################################################################################################################################
  ############### DAILY PRECIPITATIONS
  daily_sum_precip <- eventReactive(input$StartButton,
                                   {
                                     req(input$input_folder)
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
                                   req(input$input_folder)
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
                                  req(input$input_folder)
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
                                      req(input$input_folder)
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
                                   req(input$input_folder)
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
                                  req(input$input_folder)
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
                                      req(input$input_folder)
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
                                   req(input$input_folder)
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
                                  req(input$input_folder)
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
    req(input$input_folder)
    req(input$StartButton)
    req(prims_data())
    
    print('Check: Display the map')
    
    data <- prims_data()
    
    start_year <- as.numeric(year(min(data$WAKTU)))
    
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
      
      gwlts  <- ts(data$GWL, frequency=52650,start=c(start_year,10))
      smts   <- ts(data$SOILMOISTURE, frequency=52650, start=c(start_year,10))
      raints <- ts(data$RAIN, frequency=52650, start=c(start_year,10))
      }
    if(input$option_frequency == "Daily"){
      
      gwlts  <- ts(daily_avg_gwl$avg_gwl, frequency=365, start=c(start_year,1))
      smts   <- ts(daily_avg_sm$avg_sm, frequency=365, start=c(start_year,1))
      raints <- ts(daily_sum_precip$total_precip, frequency=365, start=c(start_year,1))
    }
    if(input$option_frequency == "Weekly"){
      
      gwlts  <- ts(weekly_avg_gwl$avg_gwl, frequency=52, start=c(start_year,1))
      smts   <- ts(weekly_avg_sm$avg_sm, frequency=52, start=c(start_year,1))
      raints <- ts(weekly_sum_precip$total_precip, frequency=52, start=c(start_year,1))
    }
    if(input$option_frequency == "Monthly"){
      
      gwlts  <- ts(monthly_avg_gwl$avg_gwl, frequency=12, start=c(start_year,1))
      smts   <- ts(monthly_avg_sm$avg_sm, frequency=12, start=c(start_year,1))
      raints <- ts(monthly_sum_precip$total_precip, frequency=12, start=c(start_year,1))
      }

    graph_type <- input$option_graph_type
    
    if(graph_type == "Color overlap"){
      
      ts.plot((raints*max(smts)/max(raints)), 
              (gwlts*max(smts)/max(gwlts)/20), 
              smts, 
              gpars = list(col  = c("grey", "red", "blue"),
                           ylim = c(-max(smts),max(smts))))
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
    req(input$input_folder)
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
