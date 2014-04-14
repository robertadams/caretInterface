library(shiny)
library(AppliedPredictiveModeling)
library(mlbench)
library(caret)
library(doMC)

require(devtools)
require(gbm)
require(survival)
require(splines)
require(plyr)


classificationOutput <- function(input, output) {
    registerDoMC(cores = input$cores)
    
    set.seed(808)
    
    sonarData <- Sonar[,1:length(Sonar)-1]
    sonarClasses <- Sonar$Class
    
    tuningParams <- isolate({
        switch(input$model,
               "K Nearest Neighbors" = list(k=input$k),
               "Stochastic Gradient Boosting" = list(interaction.depth=c(1,5,9),
                                                     n.trees = seq(50,input$n.trees, 50),
                                                     shrinkage = input$shrinkage))
    })
    
    fitControl <- trainControl(## 10-fold CV
        method = "repeatedcv",
        number = 10,
        ## repeated ten times
        repeats = 10,
        classProbs = TRUE,
        allowParallel = TRUE) 
    
    grid <- reactive({
        grid <- isolate({expand.grid(tuningParams)})
        return(grid)
    })
    
    gbmFit <- reactive({train(sonarData, 
                              sonarClasses,
                              method = "gbm",
                              trControl = fitControl,
                              ## Now specify the exact models 
                              ## to evaludate:
                              tuneGrid = grid(),
                              ## This last option is actually one
                              ## for gbm() that passes through
                              verbose = FALSE)})
    
    output$boxPlot <- renderPlot({
        featurePlot(x = Sonar[, 1:length(Sonar)-1],
                    y = Sonar$Class,
                    plot = "box",
                    ## Pass in options to bwplot() 
                    scales = list(y = list(relation="free"),
                                  x = list(rot = 90)),
                    layout = c(2,1 ),
                    auto.key = list(columns = 2))
    })
    
    output$modelSelectionPlot <- renderPlot({
        if (input$compute == 0)
            return(NULL)
        fit <- gbmFit()
        plot(ggplot(fit))
    })
    
    output$classificationResult <-renderDataTable({
        if (input$compute == 0)
            return(NULL)
        fit <- gbmFit()
        fit$results
    })
}

shinyServer(function(input, output) {
    output <- classificationOutput(input, output)
})