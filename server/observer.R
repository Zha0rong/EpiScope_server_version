observe( if (!is.null(reactivevalue$species)) {
  updateSelectizeInput(session,'Species','Select Species',choices=reactivevalue$species,
                       selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))

})

observe( if (!is.null(input$Species)) {
if (input$Species=='Homo sapiens') {
  updateSelectizeInput(session,'GenomeVersion','Select Genome Version',choices=c('GRCh37','GRCh38'),
                       selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))
					   }
else if (input$Species=='Mus musculus') {
  updateSelectizeInput(session,'GenomeVersion','Select Genome Version',choices=c('mm9','mm10'),
                       selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))
					   }
})

observeEvent( input$submit, {
  if (!is.null(input$Bed)) {
    msg <- sprintf('Uploading...')

    withProgress(message=msg, {
      reactivevalue$Bed=input$Bed$datapath
      reactivevalue$peak=readPeakFile(reactivevalue$Bed)
      seqlevelsStyle(reactivevalue$peak) = 'UCSC'
      setProgress(0.25, 'Finished Reading in Peaks.')
		if (input$Species=='Homo sapiens') {
		reactivevalue$annodb="org.Hs.eg.db"
		if (input$GenomeVersion=='GRCh37') {
		reactivevalue$txdb=TxDb.Hsapiens.UCSC.hg19.knownGene
			}
		else if (input$GenomeVersion=='GRCh38') {
		reactivevalue$txdb=TxDb.Hsapiens.UCSC.hg38.knownGene
			}
		}
		else if (input$Species=='Mus musculus') {
		reactivevalue$annodb="org.Mm.eg.db"
		if (input$GenomeVersion=='mm9') {
		reactivevalue$txdb=TxDb.Mmusculus.UCSC.mm9.knownGene
			}
		else if (input$GenomeVersion=='mm10') {
		reactivevalue$txdb=TxDb.Mmusculus.UCSC.mm10.knownGene
			}
		}


      setProgress(0.5, 'Finished Building Annotation.')
      reactivevalue$peakAnno <- annotatePeak(reactivevalue$peak, tssRegion=c(-3000, 3000),level = 'gene',
                                             TxDb=reactivevalue$txdb,verbose = F,annoDb = reactivevalue$annodb)
      setProgress(0.75, 'Finished Annotating Peaks.')
      output$upsetandvenn = renderPlot(upsetplot(reactivevalue$peakAnno, vennpie=TRUE))
      setProgress(1, 'Completed')

    })
    reactivevalue$peakAnnodataframe=data.frame(reactivevalue$peakAnno)
    reactivevalue$gene=unique(reactivevalue$peakAnnodataframe$SYMBOL)
    reactivevalue$gene=reactivevalue$gene[!is.na(reactivevalue$gene)]
    reactivevalue$gene=reactivevalue$gene[order(reactivevalue$gene)]
    reactivevalue$Region=unique(reactivevalue$peakAnnodataframe$annotation)

    updateSelectizeInput(session,'Gene','Gene',choices=reactivevalue$gene,
                         selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))
  }
})


observe( if (!is.null(reactivevalue$peak)) {
  chromosomal_peak_distribution=data.frame(table(reactivevalue$peak@seqnames),stringsAsFactors = F)
  colnames(chromosomal_peak_distribution)=c('Chromosome','Number of Peaks')
  chromosomal_peak_distribution=chromosomal_peak_distribution[order(as.character(chromosomal_peak_distribution$Chromosome)),]
  output$chromosomal_peak_distribution=renderDataTable(datatable(chromosomal_peak_distribution))
  length_distribution=as.numeric(reactivevalue$peak@ranges@width)
  length_distribution=data.frame(length_distribution)
  colnames(length_distribution)='width'
  length_distribution_table=data.frame(as.numeric(summary(length_distribution$width)))
  rownames(length_distribution_table)=c( 'Minimum','First Quartile',  'Median',    'Mean', 'Third Quartile',    'Maximum')
  colnames(length_distribution_table)='Statistics'
  length_distribution_table=datatable(length_distribution_table)
  plot=ggplot(length_distribution,aes(x=width))+
    geom_histogram(aes(y=..density..),
                   binwidth=100,
                   colour="black", fill="white") +
    geom_density(alpha=.2, fill="#FF6666")
  output$length_distribution=renderPlot(plot)
  output$length_distribution_table=renderDataTable(length_distribution_table)
  selectedcolumns=c('seqnames',
                    'start',
                    'end',
                    'width',
                    'annotation',
                    'geneId',
                    'distanceToTSS',
                    'SYMBOL',
                    'GENENAME')
  output$annotation_table=DT::renderDT(DT::datatable(reactivevalue$peakAnnodataframe[,selectedcolumns],rownames = F),filter = "top")

})

observe( if (!is.null(input$Gene)) {
  selectedcolumns=c('seqnames',
                    'start',
                    'end',
                    'width',
                    'annotation',
                    'geneId',
                    'distanceToTSS',
                    'SYMBOL',
                    'GENENAME')
  output$gene_annotation_table=DT::renderDT(DT::datatable(reactivevalue$peakAnnodataframe[reactivevalue$peakAnnodataframe$SYMBOL%in%input$Gene
                                                                                          ,selectedcolumns],rownames = F))
})

observe( if (!is.null(input$Region)) {
  selectedcolumns=c('seqnames',
                    'start',
                    'end',
                    'width',
                    'annotation',
                    'geneId',
                    'distanceToTSS',
                    'SYMBOL',
                    'GENENAME')
  output$region_annotation_table=DT::renderDT(DT::datatable(reactivevalue$peakAnnodataframe[grepl(input$Region,reactivevalue$peakAnnodataframe$annotation)
                                                                                          ,selectedcolumns],rownames = F))
})






observeEvent( input$TSS_heatmap_submit, {
  output$TSS_Heatmap=renderPlot(peakHeatmap(reactivevalue$peak, TxDb=reactivevalue$txdb, upstream=(input$TSS_range), downstream=input$TSS_range, color="blue"))
})





