# Cargar todas las librerias necesarias para consulta de datos GFW

load_or_install <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
    library(package, character.only = TRUE)
  }
}

load_or_install("sf")
load_or_install("httr2")
load_or_install("dbscan")
load_or_install("dplyr")

# Lectura de alertas IDEAM para conocer las fechas de las últimas dos semanas en las que
# este sistema ha publicado dicha información.
atd_IDEAM <- st_read("Data/output/IDEAM_atd.shp") 

# ______________________________________________________________________________
# Obtención de API Key 
token_GFW <- read.csv("token_autorization_GFW.csv")$token_GFW
API_Key <- read.csv("API_Key.csv")$API_Key

# Construye la URL para obtener los detalles de la clave API
url <- paste0("https://data-api.globalforestwatch.org/auth/apikey/", API_Key)

# Realiza la solicitud GET para obtener los detalles de la clave API
response <- request(url) %>%
  req_headers(Authorization = paste("Bearer", token_GFW)) %>%
  req_perform()

api_details <- resp_body_json(response)
Date_expira <- as.Date(api_details$data$expires_on)

if(Date_expira - Sys.Date() < 20){
  # URL del endpoint para crear una API key
  url <- "https://data-api.globalforestwatch.org/auth/apikey"
  
  # Cuerpo de la solicitud en formato JSON
  body_data <- list(
    alias = paste0("api-key-for-consulting-alerts1","_",Sys.Date()),
    email = "oba@jbotanico.org",
    organization = "Fundación Jardín Botánico Joaquín Antonio Uribe de Medellín",
    domains = list()  # Deja vacío si no especificas dominios
  )
  
  # Realizar la solicitud POST para crear la API key
  response <- request(url) %>%
    req_headers(
      Authorization = paste("Bearer", token_GFW),
      "Content-Type" = "application/json"
    ) %>%
    req_body_json(body_data) %>%
    req_perform()
  
  # API-KEY
  API_Key <- resp_body_json(response)$data$api_key
  write.csv(data.frame(API_Key), "API_Key.csv")
  
}else{
  API_Key <- read.csv("API_Key.csv")$API_Key
}

# ______________________________________________________________________________


# Obtención de última capa (versión) del sistema de alertas de deforestación integradas
url <- "https://data-api.globalforestwatch.org/dataset/gfw_integrated_alerts/latest/query"

# Lectura del departamento de Antioquia para realizar filtro espacial
Antioquia.geojson <- st_read("Data/input/Antioquia.geojson") |>
  st_transform(crs=4326)


## Consulta por nivel de confianza alto y muy alto de las últimas dos semanas
Fecha_hoy <- unique(atd_IDEAM$FechaFin) # Fecha actual
Fecha_previa <- unique(atd_IDEAM$FechaInit) # Fecha de hace dos semanas

subregiones <- st_read("Data/input/SubregionesAntioquia.geojson") |>
  st_transform(crs=4326)

datos_complete <- NULL
for(i in 1:9){
  Antioquia.geojson <- subregiones[i,]
  db_coords <- st_coordinates(Antioquia.geojson)[,c(1,2)]
  list_coords <- unname(split(db_coords, seq(nrow(db_coords))))
  consultaSQL <- paste0("SELECT longitude, latitude, gfw_integrated_alerts__date, gfw_integrated_alerts__confidence FROM results WHERE gfw_integrated_alerts__date > '", Fecha_previa, "' AND gfw_integrated_alerts__date < '", Fecha_hoy, "' AND (gfw_integrated_alerts__confidence = 'high' OR gfw_integrated_alerts__confidence = 'highest')")
  
  body <- list(
    geometry = list(
      type = "Polygon",
      coordinates = list(list_coords)
    ),
    sql = consultaSQL
  )
  
  
  # Realizar la solicitud POST
  # Número máximo de intentos
  max_intentos <- 8
  intento <- 1
  exito <- FALSE
  
  # Bucle que intentará ejecutar el código hasta que sea exitoso o se alcance el límite de intentos
  while (intento <= max_intentos && !exito) {
    tryCatch({
      # Código para realizar la solicitud
      response <- request(url) %>%
        req_headers(
          "x-api-key" = API_Key,  # Reemplazar con tu clave de la API
          "Content-Type" = "application/json"
        ) %>%
        req_body_json(body) %>%
        req_timeout(300) %>%
        req_perform()
      
      # Si llega aquí sin errores, se considera un éxito
      exito <- TRUE
      print("Solicitud exitosa")
      
    }, error = function(e) {
      # Mensaje de error y aumento del contador de intentos
      print(paste("Error en el intento", intento, ":", e$message))
      intento <- intento + 1
    })
  }
  
  # Imprimir la respuesta
  x <- resp_body_json(response)$data 
  
  # Convertir la lista de listas a una lista de listas con nombres de columnas
  # Extraer los elementos de cada lista interna
  df_list <- lapply(x, function(item) {
    data.frame(
      latitude = item$latitude,
      longitude = item$longitude,
      date = item$gfw_integrated_alerts__date,
      confidence = item$gfw_integrated_alerts__confidence,
      stringsAsFactors = FALSE
    )
  })
  
  # Unir todas las listas en un solo data frame
  df <- do.call(rbind, df_list)
  
  df$Fecha_inicio <- Fecha_previa
  df$Fecha_fin <- Fecha_hoy
  
  datos_complete <- rbind(datos_complete, df)
  print(paste("Subregión", i, "consultada con éxito"))
  
}


# Ver el data frame
df <- datos_complete

head(df)
unique(df$confidence)


## Clusters de puntos 
GFW_puntos <- st_as_sf(df, coords = c("longitude","latitude"),
                       crs = st_crs(4326))

GFW_puntos_planas <- st_transform(GFW_puntos, crs=3116)

confianza <- unique(GFW_puntos_planas$confidence)
subdatos_cluster <- data.frame()
for(i in confianza){
  subdatos <- subset(GFW_puntos_planas, confidence == i)
  coords <- st_coordinates(subdatos)
  dbscan_result <- dbscan(coords, eps = 12, minPts = 1)
  subdatos$cluster <- dbscan_result$cluster
  subdatos_cluster <- rbind(subdatos_cluster, subdatos)
}

subdatos_cluster$area <- (11^2)/10000


x <- subdatos_cluster |>
  group_by(confidence, cluster) |>
  summarise(NumberPuntos = n(),
            Area_ha = sum(area))

x$geometry <- st_centroid(x$geometry)

bosque <- st_read("Data/Bosque_1.shp") |> 
  st_transform(st_crs(subdatos_cluster))

atd_GFW_bosque <- st_join(subdatos_cluster, bosque)

subdatos_cluster <- subset(atd_GFW_bosque, DN == 1)

st_write(st_transform(subdatos_cluster, crs = 4326), 
         "Data/output/GFW_Alerts.shp",
         append=F)

st_write(st_transform(subdatos_cluster, crs = 4326), 
         "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/Data/output/GFW_Alerts.shp",
         append=F)

st_write(st_transform(x, crs=4326), "Data/output/GFW_AlertsCluster.shp",
         append=F)

st_write(st_transform(x, crs=4326), "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/Data/output/GFW_AlertsCluster.shp",
         append=F)



data_histG <- read.csv2("/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/data_historicov2.csv")

if(dim(data_histG)[2] > 3){
  data_histG <- data_histG[, (dim(data_histG)[2] - 2): dim(data_histG)[2]]
}else{
  data_histG <- data_histG
}

if(last(data_histG)$FechaPublicacion == Fecha_hoy){
  data_hist_export <- data_histG
}else{
  data_historico <- data.frame(FechaPublicacion = as.character(Fecha_hoy), 
                               AlertasIDEAM = dim(atd_IDEAM)[1],
                               AlertasGFW = dim(subdatos_cluster)[1])
  
  data_hist_export <- rbind(data_histG,
                            data_historico)
}


write.csv(data_hist_export, "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/Data/data_historico.csv")
write.csv2(data_hist_export, "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/data_historicov2.csv")

# write.csv(data_historico, "/Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage/Data/data_historico.csv")
