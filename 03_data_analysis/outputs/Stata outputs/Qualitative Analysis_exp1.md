. // Qualitative analysis Experiment 1
. *--------------------------------------------*
. * Step 0: Import CSV
. *--------------------------------------------*
. clear all

. set more off

. 
. * Set working directory if needed
. * cd "C:/path/to/your/files"
. 
. * Import your CSV file
. import delimited "data/ratings_combined_exp1.csv", clear
(encoding automatically selected: UTF-8)
(10 vars, 426 obs)

. 
. *--------------------------------------------*
. * Step 1: PCA to confirm component structure
. *--------------------------------------------*
. pca q1 q2 q3 q4 q5

Principal components/correlation                 Number of obs    =        426
                                                 Number of comp.  =          5
                                                 Trace            =          5
    Rotation: (unrotated = principal)            Rho              =     1.0000

    --------------------------------------------------------------------------
       Component |   Eigenvalue   Difference         Proportion   Cumulative
    -------------+------------------------------------------------------------
           Comp1 |      2.95599      2.01897             0.5912       0.5912
           Comp2 |      .937024      .412974             0.1874       0.7786
           Comp3 |       .52405      .123522             0.1048       0.8834
           Comp4 |      .400528       .21812             0.0801       0.9635
           Comp5 |      .182408            .             0.0365       1.0000
    --------------------------------------------------------------------------

Principal components (eigenvectors) 

    ------------------------------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3     Comp4     Comp5 | Unexplained 
    -------------+--------------------------------------------------+-------------
              q1 |   0.5145   -0.1619   -0.3791   -0.2584    0.7061 |           0 
              q2 |   0.5194   -0.1058   -0.2987   -0.3741   -0.6999 |           0 
              q3 |   0.4830   -0.0894   -0.0376    0.8669   -0.0754 |           0 
              q4 |   0.1838    0.9770   -0.1023   -0.0032    0.0340 |           0 
              q5 |   0.4455    0.0042    0.8690   -0.2042    0.0682 |           0 
    ------------------------------------------------------------------------------

. 
. *--------------------------------------------*
. * Step 2: Create positive_attribution score
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
. import delimited "data/ratings_combined_exp1.csv", clear
(encoding automatically selected: UTF-8)
(10 vars, 426 obs)

. gen component = "Strategy Effect"

. gen score = q4

. keep part_id agent_type component score block

. 
. * Append positive attribution rows
. append using "temp_pos.dta"
(variable component was str15, now str20 to accommodate using data's values)

. 
. *--------------------------------------------*
. * Step 3: Recode agent_type for cleaner labels
. *--------------------------------------------*
. encode agent_type, gen(agent_code)

. label define agent_lbl 1 "Heuristic-AA" 2 "DRL-HP-AA" 3 "DRL-AA"

. label values agent_code agent_lbl

. 
. 
. *--------------------------------------------*
. * Step 4: Create boxplot
. *--------------------------------------------*
. graph set window fontface "Times New Roman"

. graph set print  fontface "Times New Roman"

. graph box score, ///
>     over(agent_code, label(angle(0) labsize(medlarge))) ///
>     over(component, label(angle(0) labsize(medlarge))) ///
>     asyvars ///
>     box(1, color(blue%50)) ///
>         box(2, color(green%50)) ///
>         box(3, color(orange%50)) ///
>     ytitle("Rating Score", size(medlarge)) ///
>         ylabel(1(1)7, angle(0)) ///
>         yscale(range(0.95 9)) ///
>     graphregion(color(white)) ///
>     plotregion(margin(zero)) ///
>     legend(order(1 "Heuristic-AA" 2 "DRL-HP-AA" 3 "DRL-AA") size(medsmall)) ///
>         name(myboxplot, replace)  ///
> 

. graph display myboxplot, xsize(4) ysize(3)

. 
. *--------------------------------------------*
. * Optional: Export graph
. *--------------------------------------------*
. graph export "ratings_boxplot_exp1.png", replace
(file ratings_boxplot_exp1.png not found)
file ratings_boxplot_exp1.png saved as PNG format

. 
. encode component, gen(component_num)

. 
. *--------------------------------------------*
. * Descriptive statistics by agent and component
. *--------------------------------------------*
. bysort component agent_code: summarize score

------------------------------------------------------------------------------------------------------------------------
-> component = Positive Attribution, agent_code = Heuristic-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    5.248239    1.415622          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Positive Attribution, agent_code = DRL-HP-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    3.790493    1.615977          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Positive Attribution, agent_code = DRL-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    3.873239    1.628303          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Strategy Effect, agent_code = Heuristic-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    4.908451    2.048715          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Strategy Effect, agent_code = DRL-HP-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    4.915493    1.888723          1          7

------------------------------------------------------------------------------------------------------------------------
-> component = Strategy Effect, agent_code = DRL-AA

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       score |        142    4.978873    1.831437          1          7


. 
. *--------------------------------------------*
. * ICC check (justification for MLM)
. *--------------------------------------------*
. mixed score if component_num == 1 || part_id:, reml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -797.66747  
Iteration 1:  Log restricted-likelihood = -797.66747  

Computing standard errors ...

Mixed-effects REML regression                           Number of obs    = 426
Group variable: part_id                                 Number of groups =  71
                                                        Obs per group:
                                                                     min =   6
                                                                     avg = 6.0
                                                                     max =   6
                                                        Wald chi2(0)     =   .
Log restricted-likelihood = -797.66747                  Prob > chi2      =   .

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |   4.303991   .1305642    32.96   0.000     4.048089    4.559892
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .8785692   .2060944      .5547553    1.391395
-----------------------------+------------------------------------------------
               var(Residual) |    1.99061   .1494125      1.718289     2.30609
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 63.24         Prob >= chibar2 = 0.0000

. estat icc

Intraclass correlation

------------------------------------------------------------------------------
                       Level |        ICC   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
                     part_id |   .3062092   .0541282      .2112721    .4210343
------------------------------------------------------------------------------

. 
. mixed score if component_num == 2 || part_id:, reml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -841.95242  
Iteration 1:  Log restricted-likelihood = -841.95242  

Computing standard errors ...

Mixed-effects REML regression                           Number of obs    = 426
Group variable: part_id                                 Number of groups =  71
                                                        Obs per group:
                                                                     min =   6
                                                                     avg = 6.0
                                                                     max =   6
                                                        Wald chi2(0)     =   .
Log restricted-likelihood = -841.95242                  Prob > chi2      =   .

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |   4.934272   .1555832    31.71   0.000     4.629335     5.23921
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.321295   .2920293      .8567805    2.037653
-----------------------------+------------------------------------------------
               var(Residual) |   2.384037   .1789426      2.057894    2.761869
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 83.11         Prob >= chibar2 = 0.0000

. estat icc

Intraclass correlation

------------------------------------------------------------------------------
                       Level |        ICC   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
                     part_id |   .3565929   .0551936      .2569887    .4703631
------------------------------------------------------------------------------

. 
. *--------------------------------------------*
. * LRT chi-square for AA type effect (ML, not REML)
. *--------------------------------------------*
. // Positive Attribution
. mixed score i.block if component_num == 1 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -795.94216  
Iteration 1:  Log likelihood = -795.94216  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
                                                     Wald chi2(1)     =   1.21
Log likelihood = -795.94216                          Prob > chi2      = 0.2710

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
     2.block |   .1502347    .136483     1.10   0.271    -.1172669    .4177364
       _cons |   4.228873   .1465053    28.86   0.000     3.941728    4.516018
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .8626507   .2018092      .5453863    1.364476
-----------------------------+------------------------------------------------
               var(Residual) |   1.983839   .1489043      1.712444    2.298246
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 62.68         Prob >= chibar2 = 0.0000

. estimates store null_pa

. 
. mixed score i.agent_code i.block if component_num == 1 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -739.99563  
Iteration 1:  Log likelihood = -739.99563  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
                                                     Wald chi2(3)     = 133.20
Log likelihood = -739.99563                          Prob > chi2      = 0.0000

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
  agent_code |
  DRL-HP-AA  |  -1.457746   .1427845   -10.21   0.000    -1.737599   -1.177894
     DRL-AA  |     -1.375   .1427845    -9.63   0.000    -1.654852   -1.095148
             |
     2.block |   .1502347   .1165831     1.29   0.198    -.0782638    .3787333
       _cons |   5.173122   .1643186    31.48   0.000     4.851064    5.495181
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .9520388   .2010943      .6293028    1.440289
-----------------------------+------------------------------------------------
               var(Residual) |   1.447506   .1086479      1.249483    1.676913
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 101.81        Prob >= chibar2 = 0.0000

. estimates store full_pa

. 
. lrtest null_pa full_pa  // chi2(2) for AA type effect on positive attribution

Likelihood-ratio test
Assumption: null_pa nested within full_pa

 LR chi2(2) = 111.89
Prob > chi2 = 0.0000

. 
. // Strategy Effect
. mixed score i.block if component_num == 2 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -840.93632  
Iteration 1:  Log likelihood = -840.93632  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
                                                     Wald chi2(1)     =   0.14
Log likelihood = -840.93632                          Prob > chi2      = 0.7065

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
     2.block |    .056338   .1495874     0.38   0.706    -.2368479    .3495239
       _cons |   4.906103   .1716371    28.58   0.000     4.569701    5.242506
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.297248    .285945      .8421656    1.998244
-----------------------------+------------------------------------------------
               var(Residual) |   2.383085   .1788712      2.057072    2.760766
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 82.14         Prob >= chibar2 = 0.0000

. estimates store null_se

. 
. mixed score i.agent_code i.block if component_num == 2 || part_id:, ml

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -840.84666  
Iteration 1:  Log likelihood = -840.84666  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
                                                     Wald chi2(3)     =   0.32
Log likelihood = -840.84666                          Prob > chi2      = 0.9560

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
  agent_code |
  DRL-HP-AA  |   .0070423   .1831601     0.04   0.969     -.351945    .3660295
     DRL-AA  |   .0704225   .1831601     0.38   0.701    -.2885647    .4294098
             |
     2.block |    .056338   .1495496     0.38   0.706    -.2367738    .3494499
       _cons |   4.880282   .2015912    24.21   0.000      4.48517    5.275393
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.297449   .2859434      .8423541    1.998415
-----------------------------+------------------------------------------------
               var(Residual) |   2.381882   .1787808      2.056033    2.759372
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 82.21         Prob >= chibar2 = 0.0000

. estimates store full_se

. 
. lrtest null_se full_se  // chi2(2) for AA type effect on strategy effect

Likelihood-ratio test
Assumption: null_se nested within full_se

 LR chi2(2) =   0.18
Prob > chi2 = 0.9142

. 
. *--------------------------------------------*
. * Final REML + Kenward-Roger models for reporting
. *--------------------------------------------*
. // Positive Attribution
. mixed score i.agent_code i.block if component_num == 1 || part_id:, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood =  -744.5388  
Iteration 1:  Log restricted-likelihood =  -744.5388  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
DF method: Kenward–Roger                             DF:          min = 167.76
                                                                  avg = 305.94
                                                                  max = 352.00
                                                     F(3, 352.00)     =  44.02
Log restricted-likelihood =  -744.5388               Prob > F         = 0.0000

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  agent_code |
  DRL-HP-AA  |  -1.457746   .1433917   -10.17   0.000    -1.739759   -1.175734
     DRL-AA  |     -1.375   .1433917    -9.59   0.000    -1.657012   -1.092988
             |
     2.block |   .1502347   .1170788     1.28   0.200    -.0800272    .3804967
       _cons |   5.173122   .1653106    31.29   0.000     4.846765    5.499479
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   .9670295   .2054046      .6377314    1.466363
-----------------------------+------------------------------------------------
               var(Residual) |   1.459843   .1100398      1.259344    1.692263
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 101.39        Prob >= chibar2 = 0.0000

. contrast agent_code   // chi2(2) for AA type

Contrasts of marginal linear predictions

Margins: asbalanced

------------------------------------------------
             |         df        chi2     P>chi2
-------------+----------------------------------
score        |
  agent_code |          2      130.42     0.0000
------------------------------------------------

. margins agent_code, pwcompare(effects) mcompare(bonferroni)

Pairwise comparisons of predictive margins                 Number of obs = 426

Expression: Linear prediction, fixed portion, predict()

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
  agent_code |            3
---------------------------

--------------------------------------------------------------------------------------------
                           |            Delta-method    Bonferroni           Bonferroni
                           |   Contrast   std. err.      z    P>|z|     [95% conf. interval]
---------------------------+----------------------------------------------------------------
                agent_code |
DRL-HP-AA vs Heuristic-AA  |  -1.457746   .1433917   -10.17   0.000    -1.801023    -1.11447
   DRL-AA vs Heuristic-AA  |     -1.375   .1433917    -9.59   0.000    -1.718277   -1.031723
      DRL-AA vs DRL-HP-AA  |   .0827465   .1433917     0.58   1.000    -.2605303    .4260232
--------------------------------------------------------------------------------------------

. 
. // Strategy Effect
. mixed score i.agent_code i.block if component_num == 2 || part_id:, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -844.46744  
Iteration 1:  Log restricted-likelihood = -844.46744  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    426
Group variable: part_id                              Number of groups =     71
                                                     Obs per group:
                                                                  min =      6
                                                                  avg =    6.0
                                                                  max =      6
DF method: Kenward–Roger                             DF:          min = 184.14
                                                                  avg = 310.04
                                                                  max = 352.00
                                                     F(3, 352.00)     =   0.11
Log restricted-likelihood = -844.46744               Prob > F         = 0.9564

------------------------------------------------------------------------------
       score | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  agent_code |
  DRL-HP-AA  |   .0070423    .183939     0.04   0.969    -.3547154    .3687999
     DRL-AA  |   .0704225    .183939     0.38   0.702    -.2913351    .4321801
             |
     2.block |    .056338   .1501855     0.38   0.708    -.2390358    .3517119
       _cons |   4.880282   .2027878    24.07   0.000     4.480195    5.280368
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
part_id: Identity            |
                  var(_cons) |   1.318271   .2920657      .8539243    2.035121
-----------------------------+------------------------------------------------
               var(Residual) |   2.402182   .1810712       2.07226    2.784631
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 81.92         Prob >= chibar2 = 0.0000

. contrast agent_code   // chi2(2) for AA type

Contrasts of marginal linear predictions

Margins: asbalanced

------------------------------------------------
             |         df        chi2     P>chi2
-------------+----------------------------------
score        |
  agent_code |          2        0.18     0.9149
------------------------------------------------

. margins agent_code, pwcompare(effects) mcompare(bonferroni)

Pairwise comparisons of predictive margins                 Number of obs = 426

Expression: Linear prediction, fixed portion, predict()

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
  agent_code |            3
---------------------------

--------------------------------------------------------------------------------------------
                           |            Delta-method    Bonferroni           Bonferroni
                           |   Contrast   std. err.      z    P>|z|     [95% conf. interval]
---------------------------+----------------------------------------------------------------
                agent_code |
DRL-HP-AA vs Heuristic-AA  |   .0070423    .183939     0.04   1.000    -.4333039    .4473884
   DRL-AA vs Heuristic-AA  |   .0704225    .183939     0.38   1.000    -.3699237    .5107687
      DRL-AA vs DRL-HP-AA  |   .0633803    .183939     0.34   1.000    -.3769659    .5037265
--------------------------------------------------------------------------------------------

. 
. // Standard chi-square test (reload raw file because q6 was dropped earlier)
. import delimited "data/ratings_combined_exp1.csv", clear
(encoding automatically selected: UTF-8)
(10 vars, 426 obs)

. encode agent_type, gen(agent_code)

. 
. local q6var "q6"

. capture confirm variable q6

. if _rc != 0 {
.     capture confirm variable Q6
.     if _rc == 0 {
.         local q6var "Q6"
.     }
.     else {
.         di as error "[ERROR] q6 (or Q6) not found in ratings_combined_exp1.csv"
.         exit 111
.     }
. }

. 
. tab `q6var' agent_code, chi2 row

+----------------+
| Key            |
|----------------|
|   frequency    |
| row percentage |
+----------------+

           |            agent_code
        q6 |       DMP         RL      RL_HP |     Total
-----------+---------------------------------+----------
         0 |        38         70         67 |       175 
           |     21.71      40.00      38.29 |    100.00 
-----------+---------------------------------+----------
         1 |        83         50         51 |       184 
           |     45.11      27.17      27.72 |    100.00 
-----------+---------------------------------+----------
     Total |       121        120        118 |       359 
           |     33.70      33.43      32.87 |    100.00 

          Pearson chi2(2) =  22.0266   Pr = 0.000

. 
. // Adjusted residuals
. ssc install tab_chi
checking tab_chi consistency and verifying not already installed...
all files already exist and are up to date.

. tabchi `q6var' agent_code, r a

          observed frequency
          expected frequency
          raw residual
          adjusted residual

-------------------------------------
          |        agent_code        
       q6 |     DMP       RL    RL_HP
----------+--------------------------
        0 |      38       70       67
          |  58.983   58.496   57.521
          | -20.983   11.504    9.479
          |  -4.687    2.575    2.131
          | 
        1 |      83       50       51
          |  62.017   61.504   60.479
          |  20.983  -11.504   -9.479
          |   4.687   -2.575   -2.131
-------------------------------------

          Pearson chi2(2) =  22.0266   Pr = 0.000
 likelihood-ratio chi2(2) =  22.4439   Pr = 0.000

. 
. 
. power repeated 4.4 3.8, varerror(2.56) corr(0.4) alpha(0.05) power(0.8)

Performing iteration ...

Estimated sample size for repeated-measures ANOVA
F test for within subject with Greenhouse–Geisser correction
H0: delta = 0  versus  Ha: delta != 0

Study parameters:

        alpha =    0.0500
        power =    0.8000
        delta =    0.3423
          N_g =         1
        N_rep =         2
        means =   <matrix>
        Var_w =    0.0900
       Var_we =    0.7680
        Var_e =    2.5600
          rho =    0.4000

Estimated sample sizes:

            N =        69
  N per group =        69

. 
. 
. 
end of do-file