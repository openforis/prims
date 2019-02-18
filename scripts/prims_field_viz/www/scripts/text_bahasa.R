############################ Text boxes ENGLISH version

## t == TAB
## b == BOX
## p == PARAGRAPH
## w == WARNING


############################ TITLES
output$title    <- reactive({  "Vizualisasi pengukuran bidang PRIMS" })

output$t0_title <- reactive({  "PRIMS" })

output$source_code <- reactive({  "Kode sumber" })
output$bug_reports <- reactive({  "Laporan bug" })

############################ BUTTONS
output$download_testdata_button <- reactive({"Unduh dataset uji"})
output$select_file_button       <- reactive({"File pengukuran lapangan"})
output$start_button             <- reactive({"Tampilkan deret waktu"})


#################################################################################### 
############################ INTRODUCTION TAB
#################################################################################### 

############################ INTRODUCTION TAB - BOX 0
output$title_language <- reactive({"Bahasa"})

############################ INTRODUCTION TAB - BOX 1
output$title_description <- reactive({"Deskripsi"})

output$body_description  <- reactive({
  HTML(paste0(
    "Visualisasikan data dari pengukuran bidang PRIMS
    <br/>
    <br/> Untuk dukungan, tanyakan",
    a(href="http://www.openforis.org/support"," Open Foris support forum",target="_blank")
    ))})


output$title_download_testdata <- reactive({"Unduh data uji"})

############################ INTRODUCTION TAB - BOX 2
output$body_ts_dir  <- reactive({
  HTML(paste0(
    "Pilih file"
    )
    )})

############################ INTRODUCTION TAB - BOX 2
output$title_ts_dir  <- reactive({
  HTML(paste0("Memasukkan")
  )})

############################ INTRODUCTION TAB - BOX 2
output$title_opt_dir  <- reactive({
  HTML(paste0("Pilihan")
  )})
############################ INTRODUCTION TAB - BOX 5
output$title_result <- reactive({"Hasil"})


############################ INTRODUCTION TAB - BOX 4
output$title_disclaimer <- reactive({"Penolakan"})

output$body_disclaimer  <- reactive({
  HTML(paste0(
    "FAO menolak semua tanggung jawab atas kesalahan atau kekurangan dalam database
    atau perangkat lunak atau dalam dokumentasi yang menyertainya untuk pemeliharaan program dan
    memutakhirkan serta untuk kerusakan yang mungkin timbul dari mereka. <br/>
    FAO juga menolak tanggung jawab untuk memperbarui data dan menganggap
    tidak bertanggung jawab atas kesalahan dan kelalaian dalam data yang disediakan. <br/>
    Pengguna, bagaimanapun, diminta untuk melaporkan kesalahan atau kekurangan dalam produk ini kepada FAO."
))})







