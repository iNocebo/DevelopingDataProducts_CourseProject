clearance_sex <- function(sex) switch(sex,
                                      male = 1.23,
                                      female = 1.03)
creatinineClearance <- function(sex, bw, age, crea) sex * ((bw * (140 - age)) / crea)
vancomycinClearance <- function(creaclear) (0.689 * creaclear + 3.66) * 60 / 1000
distributionVolume <- function(bw) 0.72 * bw
halfLife <- function(vancclear, distr) logb(2, exp(1)) / (vancclear / distr)
peak <- function(doset1, distr, vancclear, int) (doset1 / distr) * (1/(1-exp(-(vancclear / distr)*int)))
trough <- function(doset1, distr, vancclear, int) (doset1 / distr) * (1/(1-exp(-(vancclear / distr)*int))) * exp(-(vancclear / distr)*int)



shinyServer(
        function(input, output) {
                output$mirror <- renderText({
                        paste("Vancomycin dose adaption for a ", input$sex, "patient, age ", input$age,",", input$bw, "kg, with a creatinine plasma concentration of ",input$crea, "µmol/L and a current vancomycin dose of ", input$doset1," mg, applied every", input$int, "hours")
                })
                temp_sex <- reactive({clearance_sex(input$sex)})
                temp_clearance <- reactive({creatinineClearance(temp_sex(), input$bw, input$age, input$crea)})
                temp_vancClearance <- reactive({vancomycinClearance(temp_clearance())})
                temp_distr <- reactive({distributionVolume(input$bw)})
                temp_hl <- reactive({halfLife(temp_vancClearance(), temp_distr())})
                temp_peak <- reactive({round(peak(input$doset1, temp_distr(), temp_vancClearance(), input$int), 2)})
                temp_trough <- reactive({round(trough(input$doset1, temp_distr(), temp_vancClearance(), input$int), 2)})
                output$pharmakokinetics <- renderTable({
                        df <- data.frame(c(temp_clearance(), temp_vancClearance(), temp_distr(), temp_hl(), temp_peak(), temp_trough()))
                        explanations <- c("> 89 mL/Min: normal kidney function; 89 - 60 mL/Min: mild renal impairment; 59 - 30 mL/Min: moderate renal impairment; 15 - 29 mL/Min: severe renal impairment; < 15 mL/Min: kidney failure", "How many litres of blood will be cleaned of Vancomycin in 1 hour?", "The theoretical volume Vancomycin will dilute itself into", "How many hours until only half of Vancomycin is still present in the body?", "Concentrations of above 20 mg/L may be toxic and lead to serious adverse drug reactions", "In the setting of non-invasive infections target trough concentration is 10 to 15 mg/L. Concentrations below 10 mg/L will promote the emergence of bacteria with elevated Vancomycin inhibitory concentrations")
                        df <- cbind(df, explanations)
                        rownames(df) <- c("Creatinine clearance [mL/Min]", "Clearance of Vancomycin [L/h]", "Volume of distribution [L]", "Half-Life of Vancomycin [h]", "Peak concentration [mg/L]", "Trough concentration [mg/L]")
                        colnames(df) <- c("Value", "Explanation")
                        df
                })
                output$documentation <- renderText({
                        paste("Vancomycin is a glycopeptide antibiotic used for 
severe bacterial infections, especially for the treatment of Methicillin-resistant 
Staphylococcus aureus - also known as MRSA. Thorough consideration of the use of 
Vancomycin and its dosing is needed to prevent the further emergence of resistant 
bacteria and to protect the patient from serious adverse drug reactions. 
But appropriate dosing requires the consideration of patient characteristics 
(weight, renal function) and infection characteristics (pathogen, infection site).
For this reason, monitoring Vancomycin concentrations is an established service in 
many hospital laboratories and pharmacies. Monitoring trough concentrations - 
the concentration present in the body 30 minutes before administering the next dose
when Vancomycin load is at its lowest - was shown to correlate with positive outcomes
considering therapy efficacy: Trough concentration of 10 - 15 mg/L should be achieved
for best therapeutic outcomes in non-severe infections. Monitoring peak concentrations
- the concentration present one hour after the administration of a intra-veneious
infusion when Vancomycin load is at its highest - was shown to be associated with
adverse drug reactions. Adverse drug reactions for Vancomycin include: Renal damage,
hearing impairment, and rash. Vancomycin elimation out of the body is heavily dependant
on the renal function of the patient: Renal impairment slows the elimination of 
Vancomycin, leading to a accumulation of the drug within the body. In patients with
renal impairment, Vancomycin dosing must be lowered or the application interval must
be widened. Renal function is measured as a function of Creatinine clearance, which 
may be calculated when plasma concentrations of Creatinine, age, gender and bodyweight are known.
The aim of this project was to develop an easy to use application to monitor patients
receiving a Vancomycin treatment. The application should support clinical decision makers
                              in their choice of drug doses and dosing intervals.")
                })
    
        }
)