
. // ANOVA - Experiment 1
. // Auto-load data (expects working directory at 03_data_analysis)
. 
. clear all

. set more off

. 
. local data_file "data/Long format Perf Experiment1.dta"

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
(213 observations deleted)

. 
. // -----------------------------------------------------------------------------
. // Describing the data
. // -----------------------------------------------------------------------------
. capture noisily tabstat TrialTime TA_Travel Congruence Human_Player_Travel, by(AgentType) statistic(mean sd min max n)

Summary statistics: Mean, SD, Min, Max, N
Group variable: AgentType (PlayerType)

AgentType |  TrialT~e  TA_Tra~l  Congru~e  Human_~l
----------+----------------------------------------
      DMP |  14.13444  1.030571  .5254873  4.177419
          |  15.44947  1.248808   .150891  4.406391
          |       3.9  .2478403  .0799439  .8762081
          |      90.1  7.368109  .8903509  38.36069
          |       284       284       284       284
----------+----------------------------------------
       RL |  49.95908  3.843003  .1263009  14.61286
          |  31.70761  2.575268  .0728866  8.599417
          |      5.84  .3550101         0  1.581948
          |     90.12  7.661974  .4006659  35.58963
          |       284       284       284       284
----------+----------------------------------------
    RL_HP |  44.42887  3.264667  .2151031  13.34132
          |  31.13422  2.391747  .0682017  8.901262
          |      5.78   .337761  .0137457  1.867453
          |     90.12  7.376506  .4633508  39.44172
          |       284       284       284       284
----------+----------------------------------------
    Total |  36.17413  2.712747  .2889638  10.71053
          |    31.374  2.469567  .2005129   8.89007
          |       3.9  .2478403         0  .8762081
          |     90.12  7.661974  .8903509  39.44172
          |       852       852       852       852
---------------------------------------------------

. capture noisily tabulate AgentType, summarize(Congruence)

            |        Summary of Congruence
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
        DMP |   .52548727   .15089097         284
         RL |   .12630087   .07288656         284
      RL_HP |   .21510314   .06820167         284
------------+------------------------------------
      Total |   .28896376   .20051292         852

. capture noisily tabulate AgentType, summarize(TA_Travel)

            |        Summary of TA_Travel
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
        DMP |   1.0305707   1.2488078         284
         RL |   3.8430034   2.5752678         284
      RL_HP |   3.2646667   2.3917465         284
------------+------------------------------------
      Total |    2.712747   2.4695666         852

. capture noisily tabulate AgentType, summarize(Human_Player_Travel)

            |   Summary of Human_Player_Travel
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
        DMP |    4.177419   4.4063908         284
         RL |   14.612858   8.5994174         284
      RL_HP |   13.341323   8.9012623         284
------------+------------------------------------
      Total |   10.710533   8.8900702         852

. capture noisily tabulate AgentType, summarize(TrialTime)

            |        Summary of TrialTime
 PlayerType |        Mean   Std. dev.       Freq.
------------+------------------------------------
        DMP |   14.134436   15.449466         284
         RL |   49.959085   31.707613         284
      RL_HP |   44.428873   31.134219         284
------------+------------------------------------
      Total |   36.174131   31.374004         852

. 
. // -----------------------------------------------------------------------------
. // ANOVA
. // -----------------------------------------------------------------------------
. 
. anova TrialTime PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        852    R-squared     =  0.5122
                         Root MSE      =    23.0366    Adj R-squared =  0.4609

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  429035.55         81   5296.7352      9.98  0.0000
                         |
                  PartID |  213022.94         70   3043.1848      5.73  0.0000
               AgentType |  211271.54          2   105635.77    199.06  0.0000
                TrialNum |  4123.5771          3   1374.5257      2.59  0.0518
      AgentType#TrialNum |  617.49973          6   102.91662      0.19  0.9785
                         |
                Residual |  408627.71        770   530.68534  
      -------------------+----------------------------------------------------
                   Total |  837663.26        851   984.32815  

. pwmean TrialTime, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
   AgentType |            3
---------------------------

---------------------------------------------------------------
              |                                 Bonferroni
    TrialTime |   Contrast   Std. err.     [95% conf. interval]
--------------+------------------------------------------------
    AgentType |
   RL vs DMP  |   35.82465   2.279423      30.35692    41.29238
RL_HP vs DMP  |   30.29444   2.279423      24.82671    35.76217
 RL_HP vs RL  |  -5.530211   2.279423     -10.99794   -.0624814
---------------------------------------------------------------

. 
. anova Congruence PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        852    R-squared     =  0.7568
                         Root MSE      =    .103964    Adj R-squared =  0.7312

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  25.892204         81   .31965683     29.57  0.0000
                         |
                  PartID |  .81038048         70   .01157686      1.07  0.3295
               AgentType |  24.951665          2   12.475832   1154.25  0.0000
                TrialNum |  .02661266          3   .00887089      0.82  0.4826
      AgentType#TrialNum |  .10354551          6   .01725759      1.60  0.1451
                         |
                Residual |  8.3226181        770   .01080859  
      -------------------+----------------------------------------------------
                   Total |  34.214822        851   .04020543  

. margins AgentType, pwcompare(effects) mcompare(bonferroni)

Pairwise comparisons of predictive margins                 Number of obs = 852

Expression: Linear prediction, predict()

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
   AgentType |            3
---------------------------

-------------------------------------------------------------------------------
              |            Delta-method    Bonferroni           Bonferroni
              |   Contrast   std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
    AgentType |
   RL vs DMP  |  -.3991864   .0087245   -45.75   0.000    -.4201184   -.3782544
RL_HP vs DMP  |  -.3103841   .0087245   -35.58   0.000    -.3313161   -.2894521
 RL_HP vs RL  |   .0888023   .0087245    10.18   0.000     .0678703    .1097343
-------------------------------------------------------------------------------

. tabstat Congruence, by(AgentType) statistic(mean sd n)

Summary for variables: Congruence
Group variable: AgentType (PlayerType)

AgentType |      Mean        SD         N
----------+------------------------------
      DMP |  .5254873   .150891       284
       RL |  .1263009  .0728866       284
    RL_HP |  .2151031  .0682017       284
----------+------------------------------
    Total |  .2889638  .2005129       852
-----------------------------------------

. 
. capture confirm variable TA_Travel

. if _rc == 0 {
.     anova TA_Travel PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        852    R-squared     =  0.5171
                         Root MSE      =    1.80412    Adj R-squared =  0.4663

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  2683.8181         81   33.133557     10.18  0.0000
                         |
                  PartID |  1395.4402         70    19.93486      6.12  0.0000
               AgentType |  1252.9546          2    626.4773    192.48  0.0000
                TrialNum |  30.272167          3   10.090722      3.10  0.0261
      AgentType#TrialNum |  5.1511249          6   .85852082      0.26  0.9536
                         |
                Residual |  2506.2258        770   3.2548387  
      -------------------+----------------------------------------------------
                   Total |  5190.0439        851    6.098759  
.     pwmean TA_Travel, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
   AgentType |            3
---------------------------

---------------------------------------------------------------
              |                                 Bonferroni
    TA_Travel |   Contrast   Std. err.     [95% conf. interval]
--------------+------------------------------------------------
    AgentType |
   RL vs DMP  |   2.812433   .1807131       2.37895    3.245915
RL_HP vs DMP  |   2.234096   .1807131      1.800613    2.667579
 RL_HP vs RL  |  -.5783366   .1807131     -1.011819    -.144854
---------------------------------------------------------------
. }

. 
. capture confirm variable Human_Player_Travel

. if _rc == 0 {
.     anova Human_Player_Travel PartID AgentType TrialNum AgentType#TrialNum

                         Number of obs =        852    R-squared     =  0.4655
                         Root MSE      =    6.83303    Adj R-squared =  0.4092

                  Source | Partial SS         df         MS        F    Prob>F
      -------------------+----------------------------------------------------
                   Model |  31305.848         81   386.49195      8.28  0.0000
                         |
                  PartID |  12433.607         70   177.62295      3.80  0.0000
               AgentType |  18411.939          2   9205.9693    197.17  0.0000
                TrialNum |  428.03621          3   142.67874      3.06  0.0277
      AgentType#TrialNum |  32.266483          6   5.3777472      0.12  0.9947
                         |
                Residual |  35951.531        770   46.690301  
      -------------------+----------------------------------------------------
                   Total |   67257.38        851   79.033348  
.     pwmean Human_Player_Travel, over(AgentType) mcompare(bonferroni)

Pairwise comparisons of means with equal variances

Over: AgentType

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
   AgentType |            3
---------------------------

---------------------------------------------------------------
              |                                 Bonferroni
Human_Playe~l |   Contrast   Std. err.     [95% conf. interval]
--------------+------------------------------------------------
    AgentType |
   RL vs DMP  |   10.43544   .6365229       8.90859    11.96229
RL_HP vs DMP  |   9.163904   .6365229      7.637055    10.69075
 RL_HP vs RL  |  -1.271535   .6365229     -2.798384    .2553141
---------------------------------------------------------------
. }

. 
. // Robustness check: random intercept vs random slope (AgentType)
. capture noisily mixed Congruence i.AgentType TrialNum || PartID:, mle

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood =  716.87224  
Iteration 1:  Log likelihood =  717.29045  
Iteration 2:  Log likelihood =  717.29174  
Iteration 3:  Log likelihood =  717.29174  

Computing standard errors ...

Mixed-effects ML regression                         Number of obs    =     852
Group variable: PartID                              Number of groups =      71
                                                    Obs per group:
                                                                 min =      12
                                                                 avg =    12.0
                                                                 max =      12
                                                    Wald chi2(3)     = 2305.46
Log likelihood =  717.29174                         Prob > chi2      =  0.0000

------------------------------------------------------------------------------
  Congruence | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
         RL  |  -.3991864   .0087303   -45.72   0.000    -.4162974   -.3820754
      RL_HP  |  -.3103841   .0087303   -35.55   0.000    -.3274951   -.2932731
             |
    TrialNum |   .0002848   .0031878     0.09   0.929    -.0059633    .0065329
       _cons |   .5244905   .0127785    41.04   0.000      .499445     .549536
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Identity             |
                  var(_cons) |   .0000492    .000166      6.64e-08    .0364957
-----------------------------+------------------------------------------------
               var(Residual) |   .0108229   .0005477       .009801    .0119514
------------------------------------------------------------------------------
LR test vs. linear model: chibar2(01) = 0.09          Prob >= chibar2 = 0.3800

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
Iteration 0:  Log likelihood =  755.59111  
Iteration 1:  Log likelihood =  757.55891  
Iteration 2:  Log likelihood =  757.58956  
Iteration 3:  Log likelihood =  757.58975  
Iteration 4:  Log likelihood =  757.58981  
Iteration 5:  Log likelihood =  757.58982  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    852
Group variable: PartID                               Number of groups =     71
                                                     Obs per group:
                                                                  min =     12
                                                                  avg =   12.0
                                                                  max =     12
                                                     Wald chi2(3)     = 825.91
Log likelihood =  757.58982                          Prob > chi2      = 0.0000

------------------------------------------------------------------------------
  Congruence | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
         RL  |  -.3991864   .0141371   -28.24   0.000    -.4268946   -.3714782
      RL_HP  |  -.3103841   .0119692   -25.93   0.000    -.3338433    -.286925
             |
    TrialNum |   .0002848   .0028766     0.10   0.921    -.0053532    .0059228
       _cons |   .5244905   .0144378    36.33   0.000      .496193     .552788
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Unstructured         |
            var(2.AgentType) |   .0097837          .             .           .
            var(3.AgentType) |   .0057653          .             .           .
                  var(_cons) |   .0053999          .             .           .
cov(2.AgentType,3.AgentType) |   .0074849          .             .           .
      cov(2.AgentType,_cons) |  -.0072105          .             .           .
      cov(3.AgentType,_cons) |  -.0055742          .             .           .
-----------------------------+------------------------------------------------
               var(Residual) |   .0088125          .             .           .
------------------------------------------------------------------------------
LR test vs. linear model: chi2(6) = 80.69                 Prob > chi2 = 0.0000

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
        m_ri |        852          .   717.2917       6  -1422.583  -1394.098
        m_rs |        852          .   757.5898       4   -1507.18  -1488.189
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.

. di as txt "[INFO] m_ri vs m_rs are compared using AIC/BIC (lrtest not valid if models are non-nested)."
[INFO] m_ri vs m_rs are compared using AIC/BIC (lrtest not valid if models are non-nested).

. 
end of do-file
