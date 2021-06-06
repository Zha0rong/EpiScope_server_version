####Genome and Genome version Handler####
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
####Take in the peak files and annotate####
observeEvent( input$submit, {
  if (!is.null(input$Bed)) {
    msg <- sprintf('Uploading...')

    withProgress(message=msg, {
      reactivevalue$Bed=input$Bed$datapath
      reactivevalue$peak=readPeakFile(reactivevalue$Bed)
      seqlevelsStyle(reactivevalue$peak) = 'UCSC'
      setProgress(0.25, 'Loading Annotation Database...')
		if (input$Species=='Homo sapiens') {
		reactivevalue$annodb="org.Hs.eg.db"
		if (input$GenomeVersion=='GRCh37') {
		  require(TxDb.Hsapiens.UCSC.hg19.knownGene)
		reactivevalue$txdb=TxDb.Hsapiens.UCSC.hg19.knownGene
			}
		else if (input$GenomeVersion=='GRCh38') {
		  require(TxDb.Hsapiens.UCSC.hg38.knownGene)
		reactivevalue$txdb=TxDb.Hsapiens.UCSC.hg38.knownGene
			}
		}
		else if (input$Species=='Mus musculus') {
		reactivevalue$annodb="org.Mm.eg.db"
		if (input$GenomeVersion=='mm9') {
		  require(TxDb.Mmusculus.UCSC.mm9.knownGene)
		reactivevalue$txdb=TxDb.Mmusculus.UCSC.mm9.knownGene
			}
		else if (input$GenomeVersion=='mm10') {
		  require(TxDb.Mmusculus.UCSC.mm10.knownGene)
		reactivevalue$txdb=TxDb.Mmusculus.UCSC.mm10.knownGene
			}
		}
      setProgress(0.5, 'Annotating peaks...')
      reactivevalue$peakAnno <- annotatePeak(reactivevalue$peak, tssRegion=c(-3000, 3000),level = 'gene',
                                             TxDb=reactivevalue$txdb,verbose = F,annoDb = reactivevalue$annodb)
      setProgress(0.75, 'Loading Annotated peaks...')
      reactivevalue$peakAnnodataframe=data.frame(reactivevalue$peakAnno)
      reactivevalue$gene=unique(reactivevalue$peakAnnodataframe$SYMBOL)
      reactivevalue$gene=reactivevalue$gene[!is.na(reactivevalue$gene)]
      reactivevalue$gene=reactivevalue$gene[order(reactivevalue$gene)]
      reactivevalue$Region=unique(reactivevalue$peakAnnodataframe$annotation)

      updateSelectizeInput(session,'Gene','Gene',choices=reactivevalue$gene,
                           selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))
      updateSelectizeInput(session,'Gene_ad','Gene',choices=reactivevalue$gene,
                           selected=NULL,options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }')))
      setProgress(1, 'Completed')
    })
    output$download_annotation <- downloadHandler(
      filename = function() {
        paste('Full_Anntotation', ".tsv", sep = "")
      },
      content = function(file) {
        write.table(reactivevalue$peakAnnodataframe, file, row.names = FALSE,quote = F,sep = '\t')
      }
    )

  }

})


observe( if (!is.null(reactivevalue$peak)) {
  chromosomal_peak_distribution=data.frame(table(reactivevalue$peak@seqnames),stringsAsFactors = F)
  colnames(chromosomal_peak_distribution)=c('Chromosome','Number of Peaks')
  chromosomal_peak_distribution=chromosomal_peak_distribution[order(as.character(chromosomal_peak_distribution$Chromosome)),]
  output$chromosomal_peak_distribution=renderDataTable(datatable(chromosomal_peak_distribution,rownames = F))
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

####Filter peak based on gene, region, gene and region####
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

  output$download_gene_annotation_table <- downloadHandler(
    filename = function() {
      paste('Peaks_associated_with_selected_genes', ".tsv", sep = "")
    },
    content = function(file) {
      write.table(reactivevalue$peakAnnodataframe[reactivevalue$peakAnnodataframe$SYMBOL%in%input$Gene
                                                  ,], file, row.names = FALSE,quote = F,sep = '\t')
    }
  )
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
  selected_region=paste(input$Region,collapse = '|')
  output$region_annotation_table=DT::renderDT(DT::datatable(reactivevalue$peakAnnodataframe[grepl(selected_region,reactivevalue$peakAnnodataframe$annotation)
                                                                                          ,selectedcolumns],rownames = F))


  output$download_region_annotation_table <- downloadHandler(
    filename = function() {
      paste('Peaks_associated_with_selected_region', ".tsv", sep = "")
    },
    content = function(file) {
      write.table(reactivevalue$peakAnnodataframe[grepl(selected_region,reactivevalue$peakAnnodataframe$annotation)
                                                  ,], file, row.names = FALSE,quote = F,sep = '\t')
    }
  )



})






observe( if (!is.null(input$Gene_ad)&!is.null(input$Region_ad)) {
  selectedcolumns=c('seqnames',
                    'start',
                    'end',
                    'width',
                    'annotation',
                    'geneId',
                    'distanceToTSS',
                    'SYMBOL',
                    'GENENAME')
  selected_region=paste(input$Region_ad,collapse = '|')
  output$ad_search_annotation_table=DT::renderDT(DT::datatable(reactivevalue$peakAnnodataframe[reactivevalue$peakAnnodataframe$SYMBOL%in%input$Gene_ad&
                                                                                                 grepl(selected_region,reactivevalue$peakAnnodataframe$annotation)
                                                                                               ,selectedcolumns],rownames = F))

  output$download_as_annotation_table <- downloadHandler(
    filename = function() {
      paste('Peaks_associated_with_searching_criteria', ".tsv", sep = "")
    },
    content = function(file) {
      write.table(reactivevalue$peakAnnodataframe[reactivevalue$peakAnnodataframe$SYMBOL%in%input$Gene_ad&grepl(selected_region,reactivevalue$peakAnnodataframe$annotation)
                                                  ,], file, row.names = FALSE,quote = F,sep = '\t')
    }
  )



})


####TSS Figure Section####
observeEvent( input$TSS_heatmap_submit, {
  msg <- sprintf('Starting TSS analysis...')

  withProgress(message=msg, {
    setProgress(0.1, 'Loading Promoter Region Database...')
    reactivevalue$promoter <- getPromoters(TxDb=reactivevalue$txdb, upstream=input$TSS_range, downstream=input$TSS_range)

    setProgress(0.5, 'Detecting peaks in Promoter Region...')
    reactivevalue$tagMatrix <- getTagMatrix(reactivevalue$peak, windows=reactivevalue$promoter)
    setProgress(1, 'Completed')
  })

  if (input$TSS_visualization_method=='Heatmap'){
    msg <- sprintf('Building figure...')

    withProgress(message=msg, {
    setProgress(0.1, 'Building figure...')

    output$TSS_Heatmap=renderPlot(tagHeatmap(reactivevalue$tagMatrix, xlim=c(-input$TSS_range, input$TSS_range), color="blue"))
    setProgress(1, 'Completed')
    })

  output$downloadTSScoverage <- downloadHandler(
    filename = paste('TSS_Heatmap', '.pdf', sep='') ,
    content = function(file) {
      msg <- sprintf('Building figure...')
      pdf(file,width = 10,height = 10) # open the pdf device

      withProgress(message=msg, {
        setProgress(0.1, 'Building figure...')

        (tagHeatmap(reactivevalue$tagMatrix, xlim=c(-input$TSS_range, input$TSS_range), color="blue"))
        setProgress(1, 'Completed')
      })
      dev.off()
    }
  )
  }
  else if (input$TSS_visualization_method=='Coverage Plot'){

    msg <- sprintf('Building figure...')

    withProgress(message=msg, {
      setProgress(0.1, 'Building figure...')

      output$TSS_Heatmap=renderPlot(plotAvgProf(reactivevalue$tagMatrix, xlim=c(-input$TSS_range, input$TSS_range)))
      setProgress(1, 'Completed')
    })
    output$downloadTSScoverage <- downloadHandler(
      filename = paste('TSS_Coverage_plot', '.pdf', sep='') ,
      content = function(file) {
        setProgress(0.1, 'Building figure...')
        pdf(file,width = 10,height = 10) # open the pdf device
        withProgress(message=msg, {
          setProgress(0.1, 'Building figure...')

          plot(plotAvgProf(reactivevalue$tagMatrix, xlim=c(-input$TSS_range, input$TSS_range)))
          setProgress(1, 'Completed')
        })
        dev.off()
      }
    )
  }
})


####Annotation Figure Section####
observeEvent( input$Annotation_figure_submit, {
  if (input$Annotation_figure_option=='Pie') {
  output$Annotation_figure=renderPlot(plotAnnoPie(reactivevalue$peakAnno))
  output$downloadannotationfigure <- downloadHandler(
    filename = paste('Annotation_figure_pie_plot', '.pdf', sep='') ,
    content = function(file) {
      pdf(file,width = 10,height = 10) # open the pdf device
      (plotAnnoPie(reactivevalue$peakAnno))
      dev.off()
    }
  )


  }
  else if (input$Annotation_figure_option=='Bar') {
    output$Annotation_figure=renderPlot(plotAnnoBar(reactivevalue$peakAnno))
    output$downloadannotationfigure <- downloadHandler(
      filename = paste('Annotation_figure_Bar_plot', '.pdf', sep='') ,
      content = function(file) {
        pdf(file,width = 10,height = 10) # open the pdf device
        plot(plotAnnoBar(reactivevalue$peakAnno))
        dev.off()
      }
    )
  }
  else if (input$Annotation_figure_option=='VennPie') {
    output$Annotation_figure=renderPlot(vennpie(reactivevalue$peakAnno))
    output$downloadannotationfigure <- downloadHandler(
      filename = paste('Annotation_figure_VennPie_plot', '.pdf', sep='') ,
      content = function(file) {
        pdf(file,width = 10,height = 10) # open the pdf device
        (vennpie(reactivevalue$peakAnno))
        dev.off()
      }
    )
  }
  else if (input$Annotation_figure_option=='upsetplot') {
    output$Annotation_figure=renderPlot(upsetplot(reactivevalue$peakAnno,vennpie=T))

    output$downloadannotationfigure <- downloadHandler(
      filename = paste('Annotation_figure_upsetplot_plot', '.pdf', sep='') ,
      content = function(file) {
        pdf(file,width = 10,height = 10) # open the pdf device
        plot(upsetplot(reactivevalue$peakAnno,vennpie=T))
        dev.off()
      }
    )
  }
})
