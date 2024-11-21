# Script para envío de Reporte a una lista de correos.

library(gmailr)

# Autenticación automática con correo OBA de gmail
gm_auth_configure(path="key_gmail_OBA.json")
gm_auth(email = TRUE)

send <- "obantioquia@gmail.com"

# Aquí iria la lista de correos
to <- c("camilomartinezcmf@gmail.com")
#to <- c("caemartinezfo@unal.edu.co")

# Composición del correo, asunto, redacción y archivos adjuntos. 
email <- gm_mime() |>
  gm_to(to) |>
  gm_from(send) |>
  gm_subject(paste("Email from R")) |> # Asunto del correo
  gm_text_body(
    paste0("Dear all", "\n",  # Cuerpo del correo
           "Hello!", "\n",
           "Hi!", "\n",
           "your text here","\n",
           "Regards", "\n",
           "Observatorio de Bosques de Antioquia.")
  ) |> 
  gm_attach_file("Reporte_pdf_dash.pdf") # Archivo de reporte adjunto



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


