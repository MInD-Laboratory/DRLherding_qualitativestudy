
. // ANOVA - Experiment 2
. // Auto-load data (expects working directory at 03_data_analysis)
. 
. clear all

. set more off

. 
. local data_file "data/Long format Perf Experiment2.dta"

. capture confirm file "`data_file'"

. if _rc {
.     di as error "[ERROR] Could not find `data_file'. Set working directory to 03_data_analysis and re-run."
.     exit 601
. }

. 
. use "`data_file'", clear

. 
. // Exclude practice trial from all analyses
. keep if TrialNum != 1
(73 observations deleted)

. 
. // -----------------------------------------------------------------------------
. // Describing the data
. // -----------------------------------------------------------------------------
. capture noisily tabstat TrialTime TA_Travel Congruence Human_Player_Travel, by(AgentType) statistic(mean sd min max n)

Summary statistics: Mean, SD, Min, Max, N
Group variable: AgentType (PlayerType)

AgentType |  TrialT~e  TA_Tra~l  Congru~e  Human_~l
----------+----------------------------------------
       RL |  50.96604  3.933898  .1157392  17.23426
          |  31.53907  2.566697  .0647769  11.28751
          |      6.08  .3648402         0  1.961558
          |      90.1  7.631937  .3384982  59.87236
          |       288       288       288       288
----------+----------------------------------------
    RL_HP |  46.52972  3.432272  .2113297  15.93861
          |  32.29911   2.50508  .0636373   11.9182
          |      5.74  .3199795  .0229008  1.551037
          |      90.1  7.276139  .4959128  74.55013
          |       288       288       288       288
----------+----------------------------------------
    Total |  48.74788  3.683085  .1635344  16.58644
          |  31.97076  2.546274  .0800254  11.61515
          |      5.74  .3199795         0  1.551037
          |      90.1  7.631937  .4959128  74.55013
          |       576       576       576       576
---------------------------------------------------

. capture noisily tabulate AgentType, summarize(Congruence)

            |        Summary of Congruence
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
         RL |   .11573919   .06477694         288
      RL_HP |   .21132967   .06363729         288
------------+------------------------------------
      Total |   .16353443   .08002541         576

. capture noisily tabulate AgentType, summarize(TA_Travel)

            |        Summary of TA_Travel
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
         RL |   3.9338977   2.5666969         288
      RL_HP |   3.4322719   2.5050802         288
------------+------------------------------------
      Total |   3.6830848   2.5462739         576

. capture noisily tabulate AgentType, summarize(Human_Player_Travel)

            |   Summary of Human_Player_Travel
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
         RL |   17.234262   11.287506         288
      RL_HP |    15.93861   11.918196         288
------------+------------------------------------
      Total |   16.586436    11.61515         576

. capture noisily tabulate AgentType, summarize(TrialTime)

            |        Summary of TrialTime
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
         RL |   50.966042   31.539073         288
      RL_HP |   46.529722   32.299111         288
------------+------------------------------------
      Total |   48.747882    31.97076         576

. 
. // -----------------------------------------------------------------------------
. // ANOVA
. // -----------------------------------------------------------------------------
. 
. anova TrialTime PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        576    R-squared     =  0.4634
                         Root MSE      =    24.5094    Adj R-squared =  0.4123

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  272350.78         50   5447.0157      9.07  0.0000
                         |
                  PartID |  237076.39         35   6773.6111     11.28  0.0000
               AgentType |  2834.0544          1   2834.0544      4.72  0.0303
                TrialNum |  26846.691          7   3835.2416      6.38  0.0000
      AgentType#TrialNum |  5593.6468          7    799.0924      1.33  0.2336
                         |
                Residual |  315373.68        525   600.71177  
      -------------------+----------------------------------------------------
                   Total |  587724.46        575   1022.1295  

. pwmean TrialTime, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

note: option bonferroni ignored since there is only one comparison
--------------------------------------------------------------
             |                                 Unadjusted
   TrialTime |   Contrast   Std. err.     [95% conf. interval]
-------------+------------------------------------------------
   AgentType |
RL_HP vs RL  |   -4.43632   2.660113     -9.661062    .7884223
--------------------------------------------------------------

. 
. anova Congruence PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        576    R-squared     =  0.4385
                         Root MSE      =    .062755    Adj R-squared =  0.3850

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  1.6147738         50   .03229548      8.20  0.0000
                         |
                  PartID |  .26182775         35   .00748079      1.90  0.0017
               AgentType |  1.3158056          1   1.3158056    334.11  0.0000
                TrialNum |  .02410832          7   .00344405      0.87  0.5264
      AgentType#TrialNum |  .01303208          7   .00186173      0.47  0.8545
                         |
                Residual |  2.0675641        525   .00393822  
      -------------------+----------------------------------------------------
                   Total |  3.6823379        575   .00640407  

. margins AgentType, pwcompare(effects) mcompare(bonferroni)

Pairwise comparisons of predictive margins                 Number of obs = 576

Expression: Linear prediction, predict()

note: option bonferroni ignored since there is only one comparison
------------------------------------------------------------------------------
             |            Delta-method    Unadjusted           Unadjusted
             |   Contrast   std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
RL_HP vs RL  |   .0955905   .0052296    18.28   0.000      .085317     .105864
------------------------------------------------------------------------------

. tabstat Congruence, by(AgentType) statistic(mean sd n)

Summary for variables: Congruence
Group variable: AgentType (PlayerType)

AgentType |      Mean        SD         N
----------+------------------------------
       RL |  .1157392  .0647769       288
    RL_HP |  .2113297  .0636373       288
----------+------------------------------
    Total |  .1635344  .0800254       576
-----------------------------------------

. 
. capture confirm variable TA_Travel

. if _rc == 0 {
.     anova TA_Travel PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        576    R-squared     =  0.4896
                         Root MSE      =     1.9038    Adj R-squared =  0.4410

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  1825.1755         50    36.50351     10.07  0.0000
                         |
                  PartID |  1569.5293         35   44.843693     12.37  0.0000
               AgentType |  36.234495          1   36.234495     10.00  0.0017
                TrialNum |  186.79745          7    26.68535      7.36  0.0000
      AgentType#TrialNum |  32.614318          7   4.6591883      1.29  0.2552
                         |
                Residual |  1902.8432        525   3.6244632  
      -------------------+----------------------------------------------------
                   Total |  3728.0187        575   6.4835108  
.     pwmean TA_Travel, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

note: option bonferroni ignored since there is only one comparison
--------------------------------------------------------------
             |                                 Unadjusted
   TA_Travel |   Contrast   Std. err.     [95% conf. interval]
-------------+------------------------------------------------
   AgentType |
RL_HP vs RL  |  -.5016258   .2113396     -.9167191   -.0865325
--------------------------------------------------------------
. }

. 
. capture confirm variable Human_Player_Travel

. if _rc == 0 {
.     anova Human_Player_Travel PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        576    R-squared     =  0.4492
                         Root MSE      =    9.02119    Adj R-squared =  0.3968

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  34848.735         50    696.9747      8.56  0.0000
                         |
                  PartID |  31383.443         35   896.66979     11.02  0.0000
               AgentType |  241.73497          1   241.73497      2.97  0.0854
                TrialNum |  2534.3227          7    362.0461      4.45  0.0001
      AgentType#TrialNum |  689.23457          7   98.462082      1.21  0.2953
                         |
                Residual |  42725.491        525   81.381888  
      -------------------+----------------------------------------------------
                   Total |  77574.226        575    134.9117  
.     pwmean Human_Player_Travel, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

note: option bonferroni ignored since there is only one comparison
--------------------------------------------------------------
             |                                 Unadjusted
Human_Play~l |   Contrast   Std. err.     [95% conf. interval]
-------------+------------------------------------------------
   AgentType |
RL_HP vs RL  |  -1.295652   .9672613     -3.195456    .6041508
--------------------------------------------------------------
. }

. 
. // Robustness check: random intercept vs random slope (AgentType)
. capture noisily mixed Congruence i.AgentType TrialNum || PartID:, mle

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood =  769.90683  
Iteration 1:  Log likelihood =  769.90692  
Iteration 2:  Log likelihood =  769.90692  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    576
Group variable: PartID                               Number of groups =     36
                                                     Obs per group:
                                                                  min =     16
                                                                  avg =   16.0
                                                                  max =     16
                                                     Wald chi2(2)     = 340.18
Log likelihood =  769.90692                          Prob > chi2      = 0.0000

------------------------------------------------------------------------------
  Congruence | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
      RL_HP  |   .0955905   .0051949    18.40   0.000     .0854086    .1057723
    TrialNum |  -.0014301   .0011336    -1.26   0.207    -.0036519    .0007918
       _cons |   .1236047    .007632    16.20   0.000     .1086462    .1385632
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Identity             |
                  var(_cons) |   .0002117   .0001082      .0000778    .0005762
-----------------------------+------------------------------------------------
               var(Residual) |   .0038861   .0002365      .0034492    .0043785
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 7.99          Prob >= chibar2 = 0.0024

. if _rc == 0 {
.     estimates store m_ri
. }

. else {
.     di as error "[WARN] Random-intercept mixed model failed with rc=" _rc
. }

. 
. capture noisily mixed Congruence i.AgentType TrialNum || PartID: i.AgentType, covariance(unstructured) mle

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood =  778.67764  
Iteration 1:  Log likelihood =  778.80418  
Iteration 2:  Log likelihood =  778.80528  
Iteration 3:  Log likelihood =  778.80528  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    576
Group variable: PartID                               Number of groups =     36
                                                     Obs per group:
                                                                  min =     16
                                                                  avg =   16.0
                                                                  max =     16
                                                     Wald chi2(2)     = 181.29
Log likelihood =  778.80528                          Prob > chi2      = 0.0000

------------------------------------------------------------------------------
  Congruence | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
      RL_HP  |   .0955905   .0071329    13.40   0.000     .0816102    .1095708
    TrialNum |  -.0014301   .0010972    -1.30   0.192    -.0035806    .0007204
       _cons |   .1236047   .0085373    14.48   0.000     .1068719    .1403375
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Unstructured         |
            var(2.AgentType) |   .0009215   .0004355       .000365    .0023269
                  var(_cons) |   .0008578   .0003108      .0004217    .0017449
      cov(2.AgentType,_cons) |  -.0008612   .0003402      -.001528   -.0001944
-----------------------------+------------------------------------------------
               var(Residual) |   .0036404   .0002293      .0032176    .0041188
------------------------------------------------------------------------------
LR test vs. linear model: chi2(3) = 25.78                 Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. if _rc == 0 {
.     estimates store m_rs
. }

. else {
.     di as error "[WARN] Random-slope mixed model failed with rc=" _rc
. }

. 
. capture noisily estimates stats m_ri m_rs

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
        m_ri |        576          .   769.9069       5  -1529.814  -1508.033
        m_rs |        576          .   778.8053       7  -1543.611  -1513.118
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.

. di as txt "[INFO] m_ri vs m_rs are compared using AIC/BIC (lrtest not valid if models are non-nested)."
[INFO] m_ri vs m_rs are compared using AIC/BIC (lrtest not valid if models are non-nested).

. 
end of do-file
