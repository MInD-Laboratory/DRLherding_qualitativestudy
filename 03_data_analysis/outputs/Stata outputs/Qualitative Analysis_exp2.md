
. // Qualitative Analysis Experiment 2
. *--------------------------------------------*
. * Step 0: Import CSV
. *--------------------------------------------*
. clear all

. set more off

. 
. * Import your Exp2 CSV file
. import delimited "data/ratings_combined_exp2.csv", clear
(encoding automatically selected: UTF-8)
(10 vars, 320 obs)

. 
. pca q1 q2 q3 q4 q5

Principal components/correlation                 Number of obs    =        320
                                                 Number of comp.  =          5
                                                 Trace            =          5
    Rotation: (unrotated = principal)            Rho              =     1.0000

    --------------------------------------------------------------------------
       Component |   Eigenvalue   Difference         Proportion   Cumulative
    -------------+------------------------------------------------------------
           Comp1 |      3.15207      2.33584             0.6304       0.6304
           Comp2 |      .816234       .36335             0.1632       0.7937
           Comp3 |      .452884    .00971566             0.0906       0.8842
           Comp4 |      .443169      .307528             0.0886       0.9729
           Comp5 |       .13564            .             0.0271       1.0000
    --------------------------------------------------------------------------

Principal components (eigenvectors) 

    ------------------------------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3     Comp4     Comp5 | Unexplained 
    -------------+--------------------------------------------------+-------------
              q1 |   0.4955   -0.2536   -0.2509   -0.4413    0.6576 |           0 
              q2 |   0.5144   -0.1675   -0.1063   -0.3757   -0.7449 |           0 
              q3 |   0.4459   -0.1961    0.8209    0.2836    0.0919 |           0 
              q4 |   0.2945    0.9306    0.1148   -0.1728    0.0649 |           0 
              q5 |   0.4520    0.0558   -0.4886    0.7442   -0.0061 |           0 
    ------------------------------------------------------------------------------

. 
. * (Optional: Check loadings to confirm component meanings)
. * pca, loading
. 
. *--------------------------------------------*
. * Step 2: Predict the first two components
. *--------------------------------------------*
. predict pc1 pc2  // Extract first two components
(score assumed)
(3 components skipped)

Scoring coefficients 
    sum of squares(column-loading) = 1

    ----------------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3     Comp4     Comp5 
    -------------+--------------------------------------------------
              q1 |   0.4955   -0.2536   -0.2509   -0.4413    0.6576 
              q2 |   0.5144   -0.1675   -0.1063   -0.3757   -0.7449 
              q3 |   0.4459   -0.1961    0.8209    0.2836    0.0919 
              q4 |   0.2945    0.9306    0.1148   -0.1728    0.0649 
              q5 |   0.4520    0.0558   -0.4886    0.7442   -0.0061 
    ----------------------------------------------------------------

. 
. *--------------------------------------------*
. * Step 1: Create positive_attribution score
. *--------------------------------------------*
. egen positive_attribution = rowmean(q1 q2 q3 q5)

. 
. * Generate a component label and score variable
. gen component = "Positive Attribution"

. gen score = positive_attribution

. 
. * Keep only needed variables and save to disk
. keep part_id agent_type component score

. save "temp_pos.dta", replace
file temp_pos.dta saved

. 
. *--------------------------------------------*
. * Step 2: Re-import data for strategy effect
. *--------------------------------------------*
. import delimited "data/ratings_combined_exp2.csv", clear
(encoding automatically selected: UTF-8)
(10 vars, 320 obs)

. gen component = "Strategy Effect"

. gen score = q4

. keep part_id agent_type component score

. 
. * Append positive attribution rows
. append using "temp_pos.dta"
(variable component was str15, now str20 to accommodate using data's values)

. 
. *--------------------------------------------*
. * Step 3: Keep only DRL agents (drop Heuristic-AA)
. *--------------------------------------------*
. 
. * Recode agent_type
. encode agent_type, gen(agent_code)

. gen agent_code_ordered = .
(640 missing values generated)

. replace agent_code_ordered = 1 if agent_code == 2  // DRL-HP-AA first
(320 real changes made)

. replace agent_code_ordered = 2 if agent_code == 1  // DRL-AA second
(320 real changes made)

. 
. label define agentlbl 1 "DRL-HP-AA" 2 "DRL-AA"

. label values agent_code_ordered agentlbl

. 
. 
. *--------------------------------------------*
. * Step 4: Create boxplot
. *--------------------------------------------*
. graph set window fontface "Times New Roman"

. graph set print  fontface "Times New Roman"

. 
. graph box score, ///
>     over(agent_code_ordered, label(angle(0) labsize(medlarge))) ///
>     over(component, label(angle(0) labsize(medlarge))) ///
>     asyvars ///
>     box(1, color(green%50)) ///
>     box(2, color(orange%50)) ///
>     ytitle("Rating Score", size(medlarge)) ///
>     ylabel(1(1)7, angle(0)) ///
>         yscale(range(0.95 9)) ///
>     graphregion(color(white)) ///
>     plotregion(margin(zero)) ///
>     legend(order(1 "DRL-HP-AA" 2 "DRL-AA") size(medsmall)) ///
>     name(myboxplot, replace)

. 
. graph display myboxplot, xsize(4) ysize(3)

. 
. *--------------------------------------------*
. * Optional: Export graph
. *--------------------------------------------*
. graph export "ratings_boxplot_exp2.png", replace
(file ratings_boxplot_exp2.png not found)
file ratings_boxplot_exp2.png saved as PNG format

. 
end of do-file