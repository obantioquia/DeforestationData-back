# Script que convierte archivo de reporte básico html al formato pdf

pagedown::chrome_print("Reporte_pdf_dash.html", 
                       output = paste0("ReportesPDF/","Reporte","_",Sys.Date(),".pdf"),
                       format="pdf", 
                       options = list(landscape = TRUE,
                                      scale = 1,
                                      marginTop = 0,
                                      marginBottom = 0,
                                      marginLeft = 0,
                                      marginRight = 0.1,
                                      paperWidth = 10, #inches
                                      paperHeight = 13, #inches
                                      #preferCSSPageSize = TRUE,
                                      pageRanges = "1-1"
                       ))


# Subir reportes a OneDrive

library(Microsoft365R)
odb <- get_business_onedrive()

odb$list_files("Reportes_PDF-integracionAlertas")

dir("ReportesPDF")

# Obtén los archivos y carpetas en el directorio
archivos <- list.files("/Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back/ReportesPDF", full.names = TRUE)

# Obtén la información de los archivos
info_archivos <- file.info(archivos)

# Ordena por fecha de modificación (mtime) de manera descendente
archivos_ordenados <- archivos[order(info_archivos$mtime, decreasing = TRUE)]

odb$upload_file("Reporte_pdf_dash.pdf", dest="Reportes_PDF-integracionAlertas/")

