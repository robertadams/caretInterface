require(devtools)

shinyUI(navbarPage("Caret Machine Learning Interface",
                   fluidPage(
                       titlePanel("Model Selection"),
                       sidebarLayout(
                           sidebarPanel(
                               selectInput("model", label="Model", 
                                           choices=c("K Nearest Neighbors", "Stochastic Gradient Boosting"),
                                           selected="Stochastic Gradient Boosting"),
                               sliderInput("cores", "Number of Cores", 1, 16, 1, step = 1),
                               hr(),
                               h3("Tuning Parameters"),
                               conditionalPanel(
                                   condition = "input.model == 'Stochastic Gradient Boosting'", 
                                   numericInput("interaction.depth", label="Tree Complexity (Interaction Depth)", value=5),
                                   numericInput("n.trees", label="Number of Iterations (Trees)", value=500),
                                   numericInput("shrinkage", label="Learning Rate (Shrinkage)", value=0.1)),
                               conditionalPanel(
                                   condition = "input.model == 'K Nearest Neighbors'",
                                   numericInput("k", label="Neighbors", value=1)),
                               br(),
                               actionButton("compute","Compute")
                           ),
                           mainPanel(
                               tabsetPanel(id="modelSelection",type="pills",position="above",
                                           tabPanel(title="Data",
                                                    fluidRow(plotOutput("boxPlot"))),
                                           tabPanel(title="Model Selection",
                                                    fluidRow(plotOutput("modelSelectionPlot"))),
                                           tabPanel(title="Result", 
                                                    fluidRow(dataTableOutput("classificationResult")))
                               ))))))