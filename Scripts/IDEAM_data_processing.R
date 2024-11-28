# Pocesamiento de los datos IDEAM descargados

load_or_install <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
    library(package, character.only = TRUE)
  }
}

load_or_install("sf")

# Esta carpeta no está en Github, sino que en el pc local donde se ejecuta el
# proyecto
setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/Alertas_IDEAM_Selenium")

# Listar archivos y ordenar con fecha mas reciente 
carpetas <- list.files(full.names = TRUE)
info_archivos <- file.info(carpetas)
archivos_ordenados <- carpetas[order(info_archivos$atime, decreasing = TRUE)]

lastFile <- archivos_ordenados[1]
sistemaAlertas <- dir(lastFile)

# Buscar todos los archivos que tengan formato shp
archivos_shp <- sistemaAlertas[grepl("\\.shp$", sistemaAlertas)]

PC_incendios <- archivos_shp[grepl("incendios", archivos_shp)]
PC <- archivos_shp[grepl("calor", archivos_shp, ignore.case = TRUE) & !grepl("incendios", archivos_shp, ignore.case = TRUE)]
atd_poligonos <- archivos_shp[grepl("pol", archivos_shp)] 
atd <- archivos_shp[grepl("atd", archivos_shp, ignore.case = TRUE) & !grepl("pol", archivos_shp, ignore.case = TRUE)]


## Lectura de shapefiles
setwd(lastFile)
PC_incendios_1 <- st_read(PC_incendios[1])
PC_incendios_2 <- st_read(PC_incendios[2])
PC_1 <- st_read(PC[1])
PC_2 <- st_read(PC[2])
atd_poligonos_1 <- st_read(atd_poligonos[1])
atd_poligonos_2 <- st_read(atd_poligonos[2])
atd_1 <- st_read(atd[1])
atd_2 <- st_read(atd[2])


## rbind de shapefiles de las dos semanas
PC_incendios <-  rbind(PC_incendios_1[, dim(PC_incendios_1)[2]],
                       PC_incendios_2[, dim(PC_incendios_2)[2]])

PC <-  rbind(PC_1[, c(1,dim(PC_1)[2])],
             PC_2[, c(1,dim(PC_2)[2])])

fecha.init <- as.Date(range(PC$Fecha..UTC)[1])
fecha.fin <- as.Date(range(PC$Fecha..UTC)[2])

lista <- list(atd_1, atd_2, atd_poligonos_1, atd_poligonos_2)


tipo <- c(as.character(st_geometry_type(atd_1)[1]), 
          as.character(st_geometry_type(atd_2)[1]), 
          as.character(st_geometry_type(atd_poligonos_1)[1]), 
          as.character(st_geometry_type(atd_poligonos_2)[1]))

tipoPunto <- which(tipo == "POINT")
tipoPoligono <- which(tipo == "POLYGON")

atd_1 <- lista[[tipoPunto[1]]]
atd_2 <- lista[[tipoPunto[2]]]

atd_poligonos_1 <- lista[[tipoPoligono[1]]]
atd_poligonos_2 <- lista[[tipoPoligono[2]]]


atd_poligonos <-  rbind(atd_poligonos_1[, dim(atd_poligonos_1)[2]],
                        atd_poligonos_2[, dim(atd_poligonos_2)[2]])

atd <-  rbind(atd_1[, dim(atd_1)[2]],
              atd_2[, dim(atd_2)[2]])


## Extracción de alertas IDEAM solo para el departamento de Antioquia
setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back")
Antioquia.geojson <- st_read("Data/input/Antioquia.geojson") |>
  st_transform(crs=4326)

PC_incendios_ant <- st_intersection(PC_incendios, Antioquia.geojson)
PC_ant <- st_intersection(PC, Antioquia.geojson)
atd_poligonos_ant <- st_intersection(atd_poligonos, Antioquia.geojson)

atd_ant <- st_intersection(atd, Antioquia.geojson)
atd_ant$FechaInit <- fecha.init
atd_ant$FechaFin <- fecha.fin



## Guardar datos filtrados a carpeta output
st_write(PC_incendios_ant, 
         "Data/output/IDEAM_PC_incendios.shp",
         append=F)

st_write(PC_ant, 
         "Data/output/IDEAM_PC.shp",
         append=F)

st_write(atd_poligonos_ant, 
         "Data/output/IDEAM_atd_poligonos.shp",
         append=F)

st_write(atd_ant, 
         "Data/output/IDEAM_atd.shp",
         append=F)



## Guardar datos filtrados a carpeta output de dashboard-website
setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage")

st_write(PC_incendios_ant, 
         "Data/output/IDEAM_PC_incendios.shp",
         append=F)

st_write(PC_ant, 
         "Data/output/IDEAM_PC.shp",
         append=F)

st_write(atd_poligonos_ant, 
         "Data/output/IDEAM_atd_poligonos.shp",
         append=F)

st_write(atd_ant, 
         "Data/output/IDEAM_atd.shp",
         append=F)

setwd("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back")
