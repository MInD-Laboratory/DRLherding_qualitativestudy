
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
file ratings_boxplot_exp1.png saved as PNG format

. 
. encode component, gen(component_num)

. 
. // Mixed model for Positive Attribution (component_num == 1)
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
                  var(_cons) |   .9670295   .2054046      .6377315    1.466363
-----------------------------+------------------------------------------------
               var(Residual) |   1.459843   .1100398      1.259344    1.692263
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 101.39        Prob >= chibar2 = 0.0000

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
. // Mixed model for Strategy Effect (component_num == 2)
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
. // Overall test of agent_code differences (only if needed)
. contrast agent_code

Contrasts of marginal linear predictions

Margins: asbalanced

------------------------------------------------
             |         df        chi2     P>chi2
-------------+----------------------------------
score        |
  agent_code |          2        0.18     0.9149
------------------------------------------------

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