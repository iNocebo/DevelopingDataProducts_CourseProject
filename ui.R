shinyUI(fluidPage(
        
        titlePanel("Vancomycin Dose Adaption in Renal Insufficiency"),
        
        sidebarLayout(
                
                sidebarPanel(
                        h3("Patient data"),
                        p("Please enter patient data"),
                        radioButtons("sex", label = "Gender", choices = c("male", "female")),
                        numericInput("age", "Age", value = 45, min = 0, max = 110, 
                                     step = 1.0),
                        numericInput("bw", "Body weight in kg", value = 70, min = 5, 
                                     max = 140, step = 1.0),
                        numericInput("crea", "Creatinine plasma concentration [µmol/L]", 
                                     value = 70, min = 0.0, max = 300, step = 1.0),
                        h3("Drug data"),
                        p("Please enter data on the current dosage regimen"),
                        numericInput("doset1", "Current dosage [mg]", value = 1000, min = 50,
                                     max = 2000, step = 25),
                        numericInput("int", "Dosing interval [h]", value = 12, min = 1,
                                     max = 48, step = 1),
                        submitButton("calculate")
                ),
                
                mainPanel(
                        tabsetPanel(
                                tabPanel("Data input mirror", textOutput("mirror")), 
                                tabPanel("Patient specific pharmakokinetics", tableOutput("pharmakokinetics")),
                                tabPanel("Documentation", textOutput("documentation"))
                                )
                )
        )
))