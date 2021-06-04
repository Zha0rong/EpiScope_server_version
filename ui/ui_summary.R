
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
               tabPanel('TSS Heatmap',
                        h3('Heatmap visualization of TSS coverage'),
                        numericInput('TSS_range','Range of TSS site',value = 2000,min = 0),
                        actionButton(inputId = 'TSS_heatmap_submit',label = 'Submit'),
                        plotOutput('TSS_Heatmap',width = '50%')
               ),
               tabPanel('Functional Annotation',
                        plotOutput('upsetandvenn')
               ),
               tabPanel('Detail Annotation',
                        DTOutput(outputId = 'annotation_table',width='75%')
               ),
               tabPanel('Extract peak based on Gene',
                        selectizeInput(inputId = 'Gene',label = 'Gene',choices = NULL,multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),

                        DTOutput(outputId = 'gene_annotation_table',width='75%')
               ),
               tabPanel('Extract peak based on Region',
                        selectizeInput(inputId = 'Region',label = 'Region',choices = c("Promoter", "5' UTR", "3' UTR", "Exon", "Intron",
                                                                                       "Downstream"),multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        DTOutput(outputId = 'region_annotation_table',width='75%')
               ),
               tabPanel('Advance Search',
                        selectizeInput(inputId = 'Gene_ad',label = 'Gene',choices = NULL,multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        selectizeInput(inputId = 'Region_ad',label = 'Region',choices = c("Promoter", "5' UTR", "3' UTR", "Exon", "Intron",
                                                                                       "Downstream"),multiple = T,selected = NULL,
                                       options=list(placeholder = 'Please select an option below',onInitialize = I('function() { this.setValue(""); }'))),
                        DTOutput(outputId = 'ad_search_annotation_table',width='75%')
               )

             )
           )
         )
)
