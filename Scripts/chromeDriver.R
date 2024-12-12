library(rvest)
library(httr2)

parsed_chrome <- read_html("https://googlechromelabs.github.io/chrome-for-testing/") 

Tabla <- as.data.frame(html_table(parsed_chrome)[[2]])
chromeDriver <- subset(Tabla, Binary == "chromedriver") 
chromeDriverMac <- subset(chromeDriver, Platform == "mac-arm64")

URL_descarga <- chromeDriverMac$URL
output_file <- "chromeDriver/chromedriver-mac-arm64.zip"

response <- request(URL_descarga) %>%
  req_perform(path = output_file)

unzip_dir <- "chromeDriver"

# Descomprimir
unzip(output_file, exdir = unzip_dir)


# dir("~/Library/Application Support/binman_chromedriver/mac64_m1")

# Llevar el descargado a la carpeta de las versiones de chromedriver

versiones <- as.data.frame(html_table(parsed_chrome)[[1]])
version_dev <- versiones$Version[1]


folder_path <- paste0("~/Library/Application Support/binman_chromedriver/mac64_m1/",version_dev)  # Cambia esta ruta según lo necesites

# Crear la carpeta
if (!dir.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  message("Carpeta creada: ", folder_path)
} else {
  message("La carpeta ya existe: ", folder_path)
}


# Mover un archivo 
# Ruta del archivo original
original_file <- "chromeDriver/chromedriver-mac-arm64/chromedriver"

# Nueva ubicación del archivo
new_file <- paste0(folder_path,"/","chromedriver")

# Mover el archivo
if (file.exists(original_file)) {
  if (file.rename(original_file, new_file)) {
    message("Archivo movido a: ", new_file)
  } else {
    message("Error al mover el archivo.")
  }
} else {
  message("El archivo original no existe: ", original_file)
}




