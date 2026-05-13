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
. keep part_id agent_type component score block

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

. keep part_id agent_type component score block

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
file ratings_boxplot_exp2.png saved as PNG format

. 
. encode component, gen(component_num)

. 
. *--------------------------------------------*
. * Step 5: Descriptive statistics by agent and component
. *--------------------------------------------*
. bysort component agent_code_ordered: summarize score

------------------------------------------------------------------------------------------------------------------------
-> component = Positive Attribution, agent_code_ordered = DRL-HP-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        160    4.946875    1.534813          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Positive Attribution, agent_code_ordered = DRL-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        160    4.471875    1.582875          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Strategy Effect, agent_code_ordered = DRL-HP-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        160      4.8875    1.919734          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Strategy Effect, agent_code_ordered = DRL-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        160        4.75    1.906625          1          7


. 
. *--------------------------------------------*
. * Step 6: ICC check (justification for MLM)
. *--------------------------------------------*
. // Positive Attribution
. mixed score if component_num == 1 || part_id:, reml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -572.87105  
Iteration 1:  Log restricted-likelihood = -572.87105  

Computing standard errors ...

Mixed-effects REML regression                           Number of obs    = 320
Group variable: part_id                                 Number of groups =  40
                                                        Obs per group:
                                                                     min =   8
                                                                     avg = 8.0
                                                                     max =   8
                                                        Wald chi2(0)     =   .
Log restricted-likelihood = -572.87105                  Prob > chi2      =   .

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |   4.709375   .1562749    30.14   0.000     4.403082    5.015668
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .7598257   .2219776      .4285895    1.347058
-----------------------------+------------------------------------------------
               var(Residual) |   1.736384   .1467512      1.471316    2.049205
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 54.98         Prob >= chibar2 = 0.0000

. estat icc

Intraclass correlation

------------------------------------------------------------------------------
                       Level |        ICC   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
                     part_id |   .3043918   .0657993      .1922358    .4458644
------------------------------------------------------------------------------

. 
. // Strategy Effect
. mixed score if component_num == 2 || part_id:, reml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -620.92418  
Iteration 1:  Log restricted-likelihood = -620.92418  

Computing standard errors ...

Mixed-effects REML regression                           Number of obs    = 320
Group variable: part_id                                 Number of groups =  40
                                                        Obs per group:
                                                                     min =   8
                                                                     avg = 8.0
                                                                     max =   8
                                                        Wald chi2(0)     =   .
Log restricted-likelihood = -620.92418                  Prob > chi2      =   .

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |    4.81875   .2063179    23.36   0.000     4.414374    5.223126
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.419536   .3863237      .8327101     2.41991
-----------------------------+------------------------------------------------
               var(Residual) |   2.265179   .1914425      1.919388    2.673266
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 82.53         Prob >= chibar2 = 0.0000

. estat icc

Intraclass correlation

------------------------------------------------------------------------------
                       Level |        ICC   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
                     part_id |     .38525   .0686638      .2620063    .5252087
------------------------------------------------------------------------------

. 
. *--------------------------------------------*
. * Step 7: LRT chi-square tests (ML, not REML)
. *--------------------------------------------*
. // Positive Attribution: null vs full model
. mixed score i.block if component_num == 1 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -571.16866  
Iteration 1:  Log likelihood = -571.16866  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
                                                     Wald chi2(1)     =   1.52
Log likelihood = -571.16866                          Prob > chi2      = 0.2173

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
     2.block |     .18125   .1469268     1.23   0.217    -.1067212    .4692212
       _cons |    4.61875   .1709039    27.03   0.000     4.283785    4.953715
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .7365759   .2137545      .4170601    1.300877
-----------------------------+------------------------------------------------
               var(Residual) |   1.726998    .145958      1.463363    2.038128
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 54.30         Prob >= chibar2 = 0.0000

. estimates store null_pa

. 
. mixed score i.agent_code_ordered i.block if component_num == 1 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood =  -565.8428  
Iteration 1:  Log likelihood =  -565.8428  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
                                                     Wald chi2(2)     =  12.44
Log likelihood =  -565.8428                          Prob > chi2      = 0.0020

------------------------------------------------------------------------------------
             score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------------+----------------------------------------------------------------
agent_code_ordered |
           DRL-AA  |      -.475   .1441585    -3.29   0.001    -.7575454   -.1924546
           2.block |     .18125   .1441585     1.26   0.209    -.1012954    .4637954
             _cons |    4.85625   .1849382    26.26   0.000     4.493778    5.218722
------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .7446351   .2136978      .4242902    1.306845
-----------------------------+------------------------------------------------
               var(Residual) |   1.662533   .1405097       1.40874     1.96205
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 57.54         Prob >= chibar2 = 0.0000

. estimates store full_pa

. 
. lrtest null_pa full_pa  // chi2(1) for agent_code effect

Likelihood-ratio test
Assumption: null_pa nested within full_pa

 LR chi2(1) =  10.65
Prob > chi2 = 0.0011

. 
. // Strategy Effect: null vs full model
. mixed score i.block if component_num == 2 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -620.21428  
Iteration 1:  Log likelihood = -620.21428  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
                                                     Wald chi2(1)     =   0.09
Log likelihood = -620.21428                          Prob > chi2      = 0.7663

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
     2.block |        .05   .1682433     0.30   0.766    -.2797508    .3797508
       _cons |    4.79375   .2204073    21.75   0.000      4.36176     5.22574
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.377059   .3719834      .8109952    2.338227
-----------------------------+------------------------------------------------
               var(Residual) |   2.264464   .1913822      1.918783    2.672423
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 81.26         Prob >= chibar2 = 0.0000

. estimates store null_se

. 
. mixed score i.agent_code_ordered i.block if component_num == 2 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -619.87991  
Iteration 1:  Log likelihood = -619.87991  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
                                                     Wald chi2(2)     =   0.76
Log likelihood = -619.87991                          Prob > chi2      = 0.6845

------------------------------------------------------------------------------------
             score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------------+----------------------------------------------------------------
agent_code_ordered |
           DRL-AA  |     -.1375   .1680425    -0.82   0.413    -.4668572    .1918572
           2.block |        .05   .1680425     0.30   0.766    -.2793572    .3793572
             _cons |     4.8625   .2358433    20.62   0.000     4.400256    5.324744
------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.377734   .3719798      .8116077    2.338754
-----------------------------+------------------------------------------------
               var(Residual) |   2.259063   .1909256      1.914206    2.666048
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 81.51         Prob >= chibar2 = 0.0000

. estimates store full_se

. 
. lrtest null_se full_se  // chi2(1) for agent_code effect

Likelihood-ratio test
Assumption: null_se nested within full_se

 LR chi2(1) =   0.67
Prob > chi2 = 0.4135

. 
. *--------------------------------------------*
. * Step 8: Final REML + Kenward-Roger models for reporting
. *--------------------------------------------*
. // Positive Attribution
. mixed score i.agent_code_ordered i.block if component_num == 1 || part_id:, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -568.81858  
Iteration 1:  Log restricted-likelihood = -568.81858  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
DF method: Kenward–Roger                             DF:          min =  77.59
                                                                  avg = 211.20
                                                                  max = 278.00
                                                     F(2, 278.00)     =   6.17
Log restricted-likelihood = -568.81858               Prob > F         = 0.0024

------------------------------------------------------------------------------------
             score | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------------+----------------------------------------------------------------
agent_code_ordered |
           DRL-AA  |      -.475   .1446761    -3.28   0.001    -.7597998   -.1902002
           2.block |     .18125   .1446761     1.25   0.211    -.1035498    .4660498
             _cons |    4.85625   .1867817    26.00   0.000     4.484365    5.228135
------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .7675609   .2219293      .4355119    1.352775
-----------------------------+------------------------------------------------
               var(Residual) |   1.674494   .1420288      1.418031    1.977341
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 57.96         Prob >= chibar2 = 0.0000

. margins agent_code_ordered, pwcompare(effects)

Pairwise comparisons of predictive margins                 Number of obs = 320

Expression: Linear prediction, fixed portion, predict()

--------------------------------------------------------------------------------------
                     |            Delta-method    Unadjusted           Unadjusted
                     |   Contrast   std. err.      z    P>|z|     [95% conf. interval]
---------------------+----------------------------------------------------------------
  agent_code_ordered |
DRL-AA vs DRL-HP-AA  |      -.475   .1446761    -3.28   0.001      -.75856     -.19144
--------------------------------------------------------------------------------------

. 
. // Strategy Effect
. mixed score i.agent_code_ordered i.block if component_num == 2 || part_id:, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -622.27129  
Iteration 1:  Log restricted-likelihood = -622.27129  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    320
Group variable: part_id                              Number of groups =     40
                                                     Obs per group:
                                                                  min =      8
                                                                  avg =    8.0
                                                                  max =      8
DF method: Kenward–Roger                             DF:          min =  68.34
                                                                  avg = 208.11
                                                                  max = 278.00
                                                     F(2, 278.00)     =   0.38
Log restricted-likelihood = -622.27129               Prob > F         = 0.6867

------------------------------------------------------------------------------------
             score | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------------+----------------------------------------------------------------
agent_code_ordered |
           DRL-AA  |     -.1375   .1686459    -0.82   0.416    -.4694852    .1944852
           2.block |        .05   .1686459     0.30   0.767    -.2819852    .3819852
             _cons |     4.8625   .2383019    20.40   0.000     4.387019    5.337981
------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.418269   .3863357      .8315566    2.418942
-----------------------------+------------------------------------------------
               var(Residual) |   2.275315   .1929897      1.926831    2.686826
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 81.86         Prob >= chibar2 = 0.0000

. margins agent_code_ordered, pwcompare(effects)

Pairwise comparisons of predictive margins                 Number of obs = 320

Expression: Linear prediction, fixed portion, predict()

--------------------------------------------------------------------------------------
                     |            Delta-method    Unadjusted           Unadjusted
                     |   Contrast   std. err.      z    P>|z|     [95% conf. interval]
---------------------+----------------------------------------------------------------
  agent_code_ordered |
DRL-AA vs DRL-HP-AA  |     -.1375   .1686459    -0.82   0.415    -.4680399    .1930399
--------------------------------------------------------------------------------------

. 
end of do-file
