# Script para envío de Reporte a una lista de correos.

library(gmailr)
library(dplyr)

# Autenticación automática con correo OBA de gmail
gm_auth_configure(path="key_gmail_OBA.json")
gm_auth(email = TRUE)

send <- "obantioquia@gmail.com"

# Aquí iria la lista de correos
# to <- c("camilomartinezcmf@gmail.com")
#to <- c("caemartinezfo@unal.edu.co")

library(gsheet)

max_intentos <- 8
intento <- 1
exito <- FALSE

while (intento <= max_intentos && !exito) {
  tryCatch({
    # Intento de enviar el mensaje
    df <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1n6jvpCRxxDo8ejJzgMh9CVvESarwq_aalncUlUnKAv8/edit?gid=875585020#gid=875585020')
    exito <- TRUE
    print("Solicitud exitosa")
    
  }, error = function(e) {
    # Manejo de errores
    print(paste("Error en el intento", intento, ":", e$message))
    
    # Incrementar el intento solo si se produce un error
    intento <- intento + 1
    
    # Opcional: agregar un pequeño retraso entre los intentos (evitar demasiados intentos consecutivos)
    Sys.sleep(2)  # Pausa de 2 segundos entre intentos, ajusta si es necesario
  })
}


inscripciones <- df |>
  select(`Correo electrónico`, `Marca temporal`) |>
  mutate(estado = 'activo')

inscripciones$`Marca temporal` <- as.POSIXct(
  inscripciones$`Marca temporal`,
  format = "%d/%m/%Y %H:%M:%S"
)


max_intentos <- 8
intento <- 1
exito <- FALSE

while (intento <= max_intentos && !exito) {
  tryCatch({
    df_cancel <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1t_K6LohLH1Rdd0sSYMysaQg2ibxU34gY_9xVAqg6fHI/edit?usp=sharing')
    exito <- TRUE
    print("Solicitud exitosa")
    
  }, error = function(e) {
    # Manejo de errores
    print(paste("Error en el intento", intento, ":", e$message))
    
    # Incrementar el intento solo si se produce un error
    intento <- intento + 1
    
    # Opcional: agregar un pequeño retraso entre los intentos (evitar demasiados intentos consecutivos)
    Sys.sleep(2)  # Pausa de 2 segundos entre intentos, ajusta si es necesario
  })
}


cancelaciones <- df_cancel |>
  select(`Correo electrónico`, `Marca temporal`) |>
  mutate(estado = 'cancelado')

cancelaciones$`Marca temporal` <- as.POSIXct(
  cancelaciones$`Marca temporal`,
  format = "%d/%m/%Y %H:%M:%S"
)

estado_actualizado <- bind_rows(inscripciones, cancelaciones) |>
  group_by(`Correo electrónico`) |>
  arrange(desc(`Marca temporal`)) |>
  slice(1) |>
  ungroup() |>
  filter(estado == "activo") 

to <- estado_actualizado$`Correo electrónico`


# Obtén los archivos y carpetas en el directorio
archivos <- list.files("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back/ReportesPDF", full.names = TRUE)

# Obtén la información de los archivos
info_archivos <- file.info(archivos)

# Ordena por fecha de modificación (mtime) de manera descendente
archivos_ordenados <- archivos[order(info_archivos$mtime, decreasing = TRUE)]

archivo_adjunto <- archivos_ordenados[1]

# Composición del correo, asunto, redacción y archivos adjuntos. 
email <- gm_mime() |>
  gm_bcc(to) |>
  gm_from(send) |>
  gm_subject(paste("Alertas de deforestación OBA")) |> # Asunto del correo
  gm_html_body(
    paste0("Alertas de deforestación OBA", "<br><br>",  # Cuerpo del correo
           "Detectamos alertas de deforestación en Antioquia.", "<br><br>",
           "Este es el reporte quincenal de las últimas alertas de deforestación del Observatorio de Bosques de Antioquia que integra los sistemas de Global Forest Watch e IDEAM.", "<br><br>",
           "<b>Consulta la versión interactiva en <a href='https://observatoriobosquesantioquia.org/integracion-alertas'>https://observatoriobosquesantioquia.org/integracion-alertas</a></b>", "<br><br>",
           "Conoce más sobre el OBA en <a href='https://observatoriobosquesantioquia.org/'>https://observatoriobosquesantioquia.org/</a>", "<br><br>",  # Texto en negrita
           "Síguenos en redes sociales:", "<br>",
           "<a href='https://www.facebook.com/ObservatorioBosquesAntioquia'>https://www.facebook.com/ObservatorioBosquesAntioquia</a>", "<br>",
           "<a href='https://www.instagram.com/bosquesantioquia/'>https://www.instagram.com/bosquesantioquia/</a>", "<br><br>",
           "¿No quieres recibir más correos? ", "<a href='https://forms.gle/V1Es1hHyDJ1K8qJ66'>Haz clic aquí para cancelar tu suscripción</a>")
  ) |> 
  gm_attach_file(archivo_adjunto) # Archivo de reporte adjunto



# A veces se generan errores por fallas en conexión a la API de gmail, el ciclo
# while asegura que se repita múltiples veces hasta que el envío sea efectivo.

max_intentos <- 8
intento <- 1
exito <- FALSE

while (intento <= max_intentos && !exito) {
  tryCatch({
    # Intento de enviar el mensaje
    gm_send_message(email)
    exito <- TRUE
    print("Solicitud exitosa")
    
  }, error = function(e) {
    # Manejo de errores
    print(paste("Error en el intento", intento, ":", e$message))
    
    # Incrementar el intento solo si se produce un error
    intento <- intento + 1
    
    # Opcional: agregar un pequeño retraso entre los intentos (evitar demasiados intentos consecutivos)
    Sys.sleep(2)  # Pausa de 2 segundos entre intentos, ajusta si es necesario
  })
}


