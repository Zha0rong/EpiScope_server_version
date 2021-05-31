
options(shiny.maxRequestSize=600*1024^2)
source('server/observer.R',local = T)






reactivevalue=reactiveValues(Bed=NULL,
                             peak=NULL,
                             peakAnno=NULL,
                             txdb=NULL,
                             peakAnnodataframe=NULL,
                             SymboltoID=NULL,
                             motifs=NULL,
                             AnnotationHub=NULL,
                             species=c('Homo sapiens','Mus musculus'),
                             select_species=NULL,
                             GenomeVersion=NULL,
                             SelectedAnnotation=NULL,
                             annodb=NULL
                             )



