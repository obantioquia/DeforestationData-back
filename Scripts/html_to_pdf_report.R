# Script que convierte archivo de reporte básico html al formato pdf

pagedown::chrome_print("Reporte_pdf_dash.html", 
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

