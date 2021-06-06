
tabPanel("Functional Visualization",

         # Application title
         titlePanel("Functional Visualization"),

         # Place for uploading data

           # Show a table of the inputted data
           mainPanel(
             tabsetPanel(
               tabPanel('TSS Visualization',
                      h3('Visualization of TSS coverage'),
                      h4('Only 10% of peak will be used to generate TSS visualization due to speed concern.'),
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

             )
             )
           )
         )

