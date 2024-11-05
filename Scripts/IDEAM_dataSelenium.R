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
                                     chromever = '128.0.6613.119',
                                     verbose = T,
                                     port = free_port())
    
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
#remDr$setTimeout(type = "implicit", milliseconds = 10000)
Estado <- FALSE
while(Estado != TRUE){
  Estado <- remDr$executeScript("return document.readyState == 'complete';")[[1]][1]
  Sys.sleep(5)
}
ElementosAlertas <- remDr$findElements(using = 'xpath', "//button[@data-automationid='FieldRenderer-name']")

data_file_names <- lapply(ElementosAlertas, function(x) {
  x$getElementText() |> unlist()
}) |> flatten_chr()


# 2. Ubicar los dos primeros 
Reciente1 <- data_file_names[1]
Reciente2 <- data_file_names[2]

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
  Sys.sleep(2)
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
  Sys.sleep(2)
}

remDr$goBack()

remDr$close()
system('taskkill /im java.exe /f')


#_______________________________________________________________________________
## Mover archivos a OneDrive personal
Sys.sleep(5)

# Obtén los archivos y carpetas en el directorio
archivos <- list.files("C:/Users/cmartinez/Downloads", full.names = TRUE)

# Obtén la información de los archivos
info_archivos <- file.info(archivos)

# Ordena por fecha de modificación (mtime) de manera descendente
archivos_ordenados <- archivos[order(info_archivos$mtime, decreasing = TRUE)]

# Muestra los archivos ordenados
print(archivos_ordenados)


# Carpeta de destino donde quieres mover los archivos
destino <- "C:/Users/cmartinez/OneDrive - JBMED/Alertas_IDEAM_Selenium"

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

setwd("C:/Users/cmartinez/OneDrive - JBMED/Alertas_IDEAM_Selenium")
directorio <- paste0(Reciente1,"____",Reciente2)
dir.create(paste0(directorio))

for(i in (length(dir())-5):length(dir())){
  unzip(dir()[i], exdir = directorio)
}

longitud <- length(dir())

deleted.files <- dir()[(longitud-5):longitud]
file.remove(deleted.files)



