
tabPanel("Summary",
         #img(src = "header.png", height="50%", width="50%", align="right"),

         # Application title
         titlePanel("Upload Bed files"),


         # Place for uploading data
         sidebarLayout(
           sidebarPanel(
             h3("Bed file Upload"),
             fileInput(
               "Bed",
               "Bedfiles",
               multiple = FALSE
             ),
            selectizeInput(inputId = 'Species',label = 'Species',choices = NULL,multiple = F,selected = NULL,
                        options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
            selectizeInput(inputId = 'GenomeVersion',label = 'GenomeVersion',choices = NULL,multiple = F,selected = NULL,
                        options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
            actionButton(inputId = 'submit',label = 'Submit')

           ),

           # Show a table of the inputted data
           mainPanel(
             tabsetPanel(
               tabPanel('Peak Summmary',
                        h3('Distribution of Domain in Genome'),
                        DT::dataTableOutput('chromosomal_peak_distribution',width = '75%'),
                        h3('Distribution of Peak Length'),

                        DT::dataTableOutput(outputId = 'length_distribution_table',width='75%'),

                        plotOutput('length_distribution',width = '75%'),
               ),
               tabPanel('TSS Visualization',
                        h3('visualization of TSS coverage'),
                        selectInput('TSS_visualization_method',
                                    'Select a Method to Visualize TSS Coverage',choices = c('Heatmap','Coverage Plot'),multiple = F,selected = 'Heatmap'
                                    ),
                        numericInput('TSS_range','Range of TSS site',value = 2000,min = 0),
                        actionButton(inputId = 'TSS_heatmap_submit',label = 'Submit'),
                        downloadButton("downloadTSScoverage", "Download TSS coverage plot"),

                        plotOutput('TSS_Heatmap',width = '50%')
               ),
               tabPanel('Functional Annotation',
                        selectInput('Annotation_figure_option',
                                    'Select a Method to Visualize Functional Annotation',choices = c('Pie','Bar',
                                                                                                     'VennPie','upsetplot'),multiple = F,selected = 'Pie'
                        ),
                        actionButton(inputId = 'Annotation_figure_submit',label = 'Submit'),
                        downloadButton("downloadannotationfigure", "Download Annotation figure"),

                        plotOutput('Annotation_figure')

               ),
               tabPanel('Detail Annotation',
                        downloadButton("download_annotation", "Download Annotation table"),

                        DTOutput(outputId = 'annotation_table',width='75%')


               ),
               tabPanel('Extract peak based on Gene',
                        selectizeInput(inputId = 'Gene',label = 'Gene',choices = NULL,multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        downloadButton("download_gene_annotation_table", "Download peak associated with selected genes"),


                        DTOutput(outputId = 'gene_annotation_table',width='75%')

               ),
               tabPanel('Extract peak based on Region',
                        selectizeInput(inputId = 'Region',label = 'Region',choices = c("Promoter", "5' UTR", "3' UTR", "Exon", "Intron",
                                                                                       "Downstream"),multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        downloadButton("download_region_annotation_table", "Download peak associated with selected regions"),

                        DTOutput(outputId = 'region_annotation_table',width='75%')

               ),
               tabPanel('Advance Search',
                        selectizeInput(inputId = 'Gene_ad',label = 'Gene',choices = NULL,multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        selectizeInput(inputId = 'Region_ad',label = 'Region',choices = c("Promoter", "5' UTR", "3' UTR", "Exon", "Intron",
                                                                                       "Downstream"),multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        downloadButton("download_as_annotation_table", "Download peak associated with searching criteria"),

                        DTOutput(outputId = 'ad_search_annotation_table',width='75%')
               )

             )
           )
         )
)
