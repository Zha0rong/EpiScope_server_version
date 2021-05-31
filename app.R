require(DT)
require(shiny)
require(shinyjs)
require(shinythemes)
require(ggplot2)
require(plotly)
require(data.table)
require(dplyr)
require(tidyr)
require(biomaRt)
require(GenomicFeatures)
require(ChIPseeker)
require(AnnotationHub)
require(AnnotationDbi)
require(magrittr)
require(TxDb.Mmusculus.UCSC.mm9.knownGene)
require(TxDb.Mmusculus.UCSC.mm10.knownGene)
require(TxDb.Hsapiens.UCSC.hg38.knownGene)
require(TxDb.Hsapiens.UCSC.hg19.knownGene)
require(org.Mm.eg.db)
require(org.Hs.eg.db)
require(ggupset)
require(ggplotify)

source('utils/Utilities.R')
source('utils/getNearestFeatureIndicesAndDistances.R')
source('utils/getGenomicAnnotation.R')
source('utils/ExtractAnnotationfromOrgDb.R')
source('utils/CompareID.R')
source('utils/AnnotatePeak_Local_AnnoDb.R')
source('utils/AddGeneAnno_Local_AnnoDb.R')

ui <- navbarPage(
  title = "EpiScope",
  id="EpiScope",
  fluid=TRUE,
  theme = shinytheme("yeti"),

  source(file.path("ui", "ui_main_page.R"),  local = TRUE)$value


)

server <- function(input, output, session) {
  source(file.path("./server/", "server.R"),  local = TRUE)$value
}

shinyApp(ui = ui, server = server)





