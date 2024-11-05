# Script para envío de Reporte a una lista de correos.

library(gmailr)

gm_auth_configure(path="key_gmail_OBA.json")
gm_auth(email = TRUE, cache = ".secret")

send <- "obantioquia@gmail.com"

# Aquí iria la lista de correos
to <- c("camilomartinezcmf@gmail.com")

email <- gm_mime() |>
  gm_to(to) |>
  gm_from(send) |>
  gm_subject(paste("Email from R")) |>
  gm_text_body(
    paste0("Dear all", "\n",
           "Hello!", "\n",
           "Hi!", "\n",
           "your text here","\n",
           "Regards", "\n",
           "Observatorio de Bosques de Antioquia.")
  ) |> 
  gm_attach_file("styles.css") # Archivo de reporte adjunto


gm_send_message(email)
