library(RSelenium)
library(wdman)
library(netstat)
library(tidyverse)

Sys.setlocale("LC_ALL", "Spanish_Spain.1252")  # Para configuraciones en español


success <- FALSE  # Inicialmente la conexión no tiene éxito
intentos <- 0     # Contador de intentos

while (!success) {
  intentos <- intentos + 1
  cat("Intento:", intentos, "\n")

  tryCatch({
    # Ejecuta el código de rsDriver
    remote_driver_object <- rsDriver(browser = 'chrome',
                                     chromever = '131.0.6778.85',
                                     verbose = T,
                                     port = 33112L)

    # Si se ejecuta correctamente
    success <- TRUE  # El código fue exitoso, salir del bucle
    cat("Conexión exitosa\n")

  }, error = function(e) {
    cat("Error en intento:", intentos, "- ", e$message, "\n")
    Sys.sleep(5)  # Esperar 5 segundos antes de intentar de nuevo (opcional)
  })
}


# Create a client object
remDr <- remote_driver_object$client

#remDr$open()
remDr$maxWindowSize()

# navigate to oneDrive
#remDr$navigate('https://onedrive.live.com/login/')
remDr$navigate("https://ideamcol-my.sharepoint.com/personal/ggalindo_ideam_gov_co/_layouts/15/onedrive.aspx?web=1&id=%2Fpersonal%2Fggalindo%5Fideam%5Fgov%5Fco%2FDocuments%2FAlertas%20Tempranas%20Deforestacion&FolderCTID=0x0120002777EE4A6EE69C4BAD5F9A1467185490&view=0")

# if(remDr$executeScript("return document.readyState == 'complete';")[[1]][1] == TRUE){
#   Correo <- remDr$findElement(using = 'xpath', '//input[@type="email"]')
#   Correo$sendKeysToElement(list("oba@jbotanico.org"))
#   Siguiente <- remDr$findElement(using = 'xpath', '//input[@type="submit"]')
#   Siguiente$clickElement()
# }else{
#   Sys.sleep(5)
# }

Estado <- FALSE
while(Estado != TRUE){
  Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
  Sys.sleep(5)
}

Correo <- remDr$findElement(using = 'xpath', '//input[@type="email"]')
Correo$sendKeysToElement(list("oba@jbotanico.org"))
Siguiente <- remDr$findElement(using = 'xpath', '//input[@type="submit"]')
Siguiente$clickElement()


#iframe <- remDr$findElement(using = 'xpath', '//iframe')
#remDr$switchToFrame(iframe)


#remDr$switchToFrame(iframe)

Estado <- FALSE
while(Estado != TRUE){
  Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
  Sys.sleep(5)
}
password <- remDr$findElement(using = 'xpath', '//input[@type="password"]')
password$sendKeysToElement(list("ObservatorioGFW.2023"))
Login <- remDr$findElement(using = 'xpath', '//input[@type="submit"]')
Login$clickElement()


Estado <- FALSE
while(Estado != TRUE){
  Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
  Sys.sleep(5)
}

No <- remDr$findElement(using = 'xpath', '//input[@type="button"]')
No$clickElement()


# Shared <- remDr$findElement(using = 'link text', 'Compartido')
# Shared$clickElement()


# Alertas IDEAM
# AlertasIDEAM <- remDr$findElement(using = 'xpath', "//button[@title='Alertas Tempranas Deforestacion']")
# AlertasIDEAM$clickElement()


# 1. Listar todos los elementos
remDr$setTimeout(type = "script", milliseconds = 30000)
Estado <- FALSE
while(Estado != TRUE){
  Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
  Sys.sleep(5)
}

# Ordenar por nombre







# Sys.sleep(15)
# nombre <- remDr$findElement(using = 'xpath', '//span[text()="Nombre"]')
# nombre$clickElement()
# Sys.sleep(10)
# Z_a_la_A <- remDr$findElement(using = 'xpath', '//button[.//span[text()="De la Z a la A"]]')
# Z_a_la_A$clickElement()

Sys.sleep(12)

ElementosAlertas <- remDr$findElements(using = 'xpath', "//button[@data-automationid='FieldRenderer-name']")

data_file_names <- lapply(ElementosAlertas, function(x) {
  x$getElementText() |> unlist()
}) |> flatten_chr()


load("subcarpetasAlertasIDEAM.RData")

data_file_names <- sort(data_file_names, decreasing=TRUE)

data_file_names_previous

#dplyr::setdiff(data_file_names, data_file_names_previous)

index_previo <- which(data_file_names == data_file_names_previous)[1]

if(index_previo == 1){
  print("No han habido actualizaciones de alertas IDEAM")
  Sys.sleep(5)
  remDr$close()
#  next
}else{
  files_download <- data_file_names[1:index_previo-1]
  
  # 2. Ubicar los dos primeros
  Reciente1 <- files_download[1]
  Reciente2 <- files_download[2]
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  # 3. Acceder a cada subcarpeta y descargar la información.
  ## 3.1. Descargar la primera mas reciente
  Last1 <- remDr$findElement(using = 'xpath', paste0("//button[@title='", Reciente1, "']"))
  Last1$clickElement()
  
  # - Archivos atd
  # Intentar listar todos los elementos
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
                        lapply(function(x) {
                          x$getElementText() |> unlist()
                          }) |> flatten_chr()
  
  atd_shape <- Elementos_lista[-c(1,2)]
  for(i in 1:length(atd_shape)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",atd_shape[i],"']"))$clickElement()
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  # - going to Puntos de calor
  remDr$findElement(using = 'xpath', "//button[@title = 'Puntos de calor']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
    lapply(function(x) {
      x$getElementText() |> unlist()
    }) |> flatten_chr()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  for(i in 1:length(Elementos_lista)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",Elementos_lista[i],"']"))$clickElement()
    Sys.sleep(3)
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  
  
  # - going to Poligonos
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//button[@title = 'Poligonos']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
    lapply(function(x) {
      x$getElementText() |> unlist()
    }) |> flatten_chr()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  for(i in 1:length(Elementos_lista)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",Elementos_lista[i],"']"))$clickElement()
    Sys.sleep(3)
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  
  
  
  
  ## 3.2. Descargar la segunda mas reciente
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Last1 <- remDr$findElement(using = 'xpath', paste0("//button[@title='", Reciente2, "']"))
  Last1$clickElement()
  
  remDr$setTimeout(type = "script", milliseconds = 30000) # Aumentar a 30 segundos
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  # - Archivos atd
  # Intentar listar todos los elementos
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
    lapply(function(x) {
      x$getElementText() |> unlist()
    }) |> flatten_chr()
  
  
  atd_shape <- Elementos_lista[-c(1,2)]
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  for(i in 1:length(atd_shape)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",atd_shape[i],"']"))$clickElement()
    Sys.sleep(5)
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  # - going to Puntos de calor
  
  remDr$findElement(using = 'xpath', "//button[@title = 'Puntos de calor']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
    lapply(function(x) {
      x$getElementText() |> unlist()
    }) |> flatten_chr()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  for(i in 1:length(Elementos_lista)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",Elementos_lista[i],"']"))$clickElement()
    Sys.sleep(5)
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  # - going to Poligonos
  remDr$findElement(using = 'xpath', "//button[@title = 'Poligonos']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
    lapply(function(x) {
      x$getElementText() |> unlist()
    }) |> flatten_chr()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  for(i in 1:length(Elementos_lista)){
    remDr$findElement(using = 'xpath', paste0("//div[@title = '",Elementos_lista[i],"']"))$clickElement()
    Sys.sleep(5)
  }
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  
  Estado <- FALSE
  while(Estado != TRUE){
    Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
    Sys.sleep(5)
  }
  
  remDr$goBack()
  #_______________________________________________________________________________
  ## Mover archivos a OneDrive personal
  Sys.sleep(5)
  
  # Obtén los archivos y carpetas en el directorio
  archivos <- list.files("/Users/investigadora/Downloads", full.names = TRUE)
  
  # Obtén la información de los archivos
  info_archivos <- file.info(archivos)
  
  # Ordena por fecha de modificación (mtime) de manera descendente
  archivos_ordenados <- archivos[order(info_archivos$mtime, decreasing = TRUE)]
  
  # Muestra los archivos ordenados
  print(archivos_ordenados)
  
  
  # Carpeta de destino donde quieres mover los archivos
  destino <- "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Alertas_IDEAM_Selenium"
  
  # Selecciona los archivos de interés (por ejemplo, los 3 más recientes)
  archivos_a_mover <- archivos_ordenados[1:6]
  
  # Mover los archivos a la carpeta de destino
  sapply(archivos_a_mover, function(archivo) {
    # Extraer el nombre base del archivo
    nombre_archivo <- basename(archivo)
  
    # Crear la ruta completa de destino
    destino_completo <- file.path(destino, nombre_archivo)
  
    # Mover el archivo
    file.rename(archivo, destino_completo)
  })
  
  #setwd("/Users/investigadora/OneDrive - JBMED/Alertas_IDEAM_Selenium")
  
  setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/Alertas_IDEAM_Selenium")
  
  directorio <- paste0(Reciente1,"____",Reciente2)
  
  #dir.create(paste0(directorio))
  
  if (!dir.exists(paste0(getwd(), "/", directorio))) {
    dir.create(paste0(getwd(), "/", directorio))
  }
  
  for(i in (length(dir())-5):length(dir())){
    unzip(paste0(getwd(),"/",dir()[i]), exdir = paste0(getwd(),"/",directorio),
          overwrite = TRUE)
  }
  
  longitud <- length(dir())
  
  deleted.files <- dir()[(longitud-5):longitud]
  file.remove(deleted.files)
  
  # Ahora se verifica que la diferencia de carpetas de alertas sea mayor a 2, en 
  # caso afirmativo se descargan solo las alertas
  
  setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back")
  
  if(length(files_download) > 2){ 
    
    for(i in 3:length(files_download)){
      
      Estado <- FALSE
      while(Estado != TRUE){
        Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
        Sys.sleep(5)
      }
      # 3. Acceder a cada subcarpeta y descargar la información.
      ## 3.1. Descargar la primera mas reciente
      Last1 <- remDr$findElement(using = 'xpath', paste0("//button[@title='", files_download[i], "']"))
      Last1$clickElement()
      
      # - Archivos atd
      # Intentar listar todos los elementos
      Estado <- FALSE
      while(Estado != TRUE){
        Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
        Sys.sleep(5)
      }
      
      Elementos_lista <- remDr$findElements(using = 'xpath', "//button[@data-automationid = 'FieldRenderer-name']") |>
        lapply(function(x) {
          x$getElementText() |> unlist()
        }) |> flatten_chr()
      
      atd_shape <- Elementos_lista[-c(1,2)]
      for(i in 1:length(atd_shape)){
        remDr$findElement(using = 'xpath', paste0("//div[@title = '",atd_shape[i],"']"))$clickElement()
      }
      
      Estado <- FALSE
      while(Estado != TRUE){
        Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
        Sys.sleep(5)
      }
      
      remDr$findElement(using = 'xpath', "//i[@data-icon-name = 'download']")$clickElement()
      
      Estado <- FALSE
      while(Estado != TRUE){
        Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
        Sys.sleep(5)
      }
      
      remDr$goBack()
      
      Estado <- FALSE
      while(Estado != TRUE){
        Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
        Sys.sleep(5)
      }
    }
    
    # Se descargan los archivos, ahora falta procesarlos
    
    ## Mover archivos a OneDrive personal
    Sys.sleep(5)
    
    # Obtén los archivos y carpetas en el directorio
    archivos <- list.files("/Users/investigadora/Downloads", full.names = TRUE)
    
    # Obtén la información de los archivos
    info_archivos <- file.info(archivos)
    
    # Ordena por fecha de modificación (mtime) de manera descendente
    archivos_ordenados <- archivos[order(info_archivos$mtime, decreasing = TRUE)]
    
    # Muestra los archivos ordenados
    print(archivos_ordenados)
    
    
    # Carpeta de destino donde quieres mover los archivos
    destino <- "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Alertas_IDEAM_Selenium_historico"
    
    # Selecciona los archivos de interés (por ejemplo, los 6 más recientes)
    archivos_a_mover <- archivos_ordenados[1:length(3:length(files_download))]
    
    # Mover los archivos a la carpeta de destino
    sapply(archivos_a_mover, function(archivo) {
      # Extraer el nombre base del archivo
      nombre_archivo <- basename(archivo)
      
      # Crear la ruta completa de destino
      destino_completo <- file.path(destino, nombre_archivo)
      
      # Mover el archivo
      file.rename(archivo, destino_completo)
    })
    
    #setwd("/Users/investigadora/OneDrive - JBMED/Alertas_IDEAM_Selenium")
    
    setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/Alertas_IDEAM_Selenium_historico")
    
    directorio <- paste0("Alerts_hist","_",Sys.Date())
    
    #dir.create(paste0(directorio))
    
    if (!dir.exists(paste0(getwd(), "/", directorio))) {
      dir.create(paste0(getwd(), "/", directorio))
    }
    
    for(i in (length(dir())- (length(3:length(files_download))-1)):length(dir())){
      
      if (!dir.exists(paste0(getwd(), "/", directorio,"/", i))) {
        dir.create(paste0(getwd(), "/", directorio,"/", i))
      }
      
      unzip(paste0(getwd(),"/",dir()[i]), exdir = paste0(getwd(),"/",directorio,"/", i),
            overwrite = TRUE)
    }
    
    longitud <- length(dir())
    
    deleted.files <- dir()[(longitud-(length(3:length(files_download))-1)):longitud]
    file.remove(deleted.files)
    
    
    ####
    
    
    
    
    
    
  }else{
    next
  }
  
  source("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back/Scripts/IDEAM_data_processing.R")
  
}




remDr$close()
#system('taskkill /im java.exe /f')


data_file_names_previous <- data_file_names[1:2]
save(data_file_names_previous, file="subcarpetasAlertasIDEAM.RData")






