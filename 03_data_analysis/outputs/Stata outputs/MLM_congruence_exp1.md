
. // Mixed effects model for congrunce_ Experiment1
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

. // Exclude practice trial from all analyses
. keep if TrialNum != 1
(213 observations deleted)

. 
. 
. // We will fit a linear mixed-effects model, with observations nested under participant. In addition to a random-intercept for each participant, we include a random slope for Ag
> entType.
. 
. // Fixed effects will include AgentType, TrialNum (to control for learning) and an AgentType x TrialNum interaction
. 
. // We will treat TrialNum as a continuous covariate to understand average learning slope
. 
. // We use Congruence1, which is Congruence z-scored.
. 
. // First test if 2-way model significantly improves model fit
. mixed Congruence1 i.AgentType c.TrialNum || PartID: i.AgentType

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -667.63431  
Iteration 1:  Log likelihood = -664.09187  
Iteration 2:  Log likelihood = -663.98497  
Iteration 3:  Log likelihood = -663.98497  

Computing standard errors ...

Mixed-effects ML regression                         Number of obs    =     852
Group variable: PartID                              Number of groups =      71
                                                    Obs per group:
                                                                 min =      12
                                                                 avg =    12.0
                                                                 max =      12
                                                    Wald chi2(3)     = 2269.15
Log likelihood = -663.98497                         Prob > chi2      =  0.0000

------------------------------------------------------------------------------
 Congruence1 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
         RL  |  -2.019803   .0448876   -45.00   0.000    -2.107781   -1.931825
      RL_HP  |  -1.570481   .0440095   -35.69   0.000    -1.656738   -1.484224
             |
    TrialNum |    .001441     .01607     0.09   0.929    -.0300556    .0329377
       _cons |   1.207603   .0644451    18.74   0.000     1.081293    1.333913
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |   .0055422   .0133547      .0000493    .6234127
            var(3.AgentType) |   1.04e-09   3.38e-09      1.80e-12    6.02e-07
                  var(_cons) |   .0015084   .0044259      4.80e-06    .4743715
-----------------------------+------------------------------------------------
               var(Residual) |   .2750313    .014704      .2476705    .3054147
------------------------------------------------------------------------------
LR test vs. linear model: chi2(3) = 0.28                  Prob > chi2 = 0.9636

Note: LR test is conservative and provided only for reference.

. estimates store m1

. 
. mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -667.06599  
Iteration 1:  Log likelihood = -663.53499  
Iteration 2:  Log likelihood = -663.42561  
Iteration 3:  Log likelihood =  -663.4256  

Computing standard errors ...

Mixed-effects ML regression                         Number of obs    =     852
Group variable: PartID                              Number of groups =      71
                                                    Obs per group:
                                                                 min =      12
                                                                 avg =    12.0
                                                                 max =      12
                                                    Wald chi2(5)     = 2272.73
Log likelihood =  -663.4256                         Prob > chi2      =  0.0000

--------------------------------------------------------------------------------------
         Congruence1 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
---------------------+----------------------------------------------------------------
           AgentType |
                 RL  |  -1.903945   .1447904   -13.15   0.000    -2.187729   -1.620161
              RL_HP  |  -1.589011   .1445148   -11.00   0.000    -1.872255   -1.305767
                     |
            TrialNum |   .0107104   .0278119     0.39   0.700    -.0437999    .0652207
                     |
AgentType#c.TrialNum |
                 RL  |  -.0331023    .039332    -0.84   0.400    -.1101915     .043987
              RL_HP  |   .0052941    .039332     0.13   0.893    -.0717951    .0823833
                     |
               _cons |    1.17516   .1022941    11.49   0.000     .9746675    1.375653
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |   .0056602   .0133684      .0000553    .5797354
            var(3.AgentType) |   1.02e-09   3.02e-09      3.01e-12    3.44e-07
                  var(_cons) |   .0015486   .0044292      5.69e-06    .4211675
-----------------------------+------------------------------------------------
               var(Residual) |    .274593   .0146836      .2472704    .3049347
------------------------------------------------------------------------------
LR test vs. linear model: chi2(3) = 0.29                  Prob > chi2 = 0.9611

Note: LR test is conservative and provided only for reference.

. estimates store m2

. 
. lrtest m1 m2 // chi2(2) = 6.91, p = .0315. 2-way model provides better fit.

Likelihood-ratio test
Assumption: m1 nested within m2

 LR chi2(2) =   1.12
Prob > chi2 = 0.5716

. 
. // To adjust for small samples, refit model with REML with Kenward-Roger estimates of error dof
. mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -682.60559  
Iteration 1:  Log restricted-likelihood = -679.10179  
Iteration 2:  Log restricted-likelihood = -678.98651  
Iteration 3:  Log restricted-likelihood = -678.98651  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    852
Group variable: PartID                               Number of groups =     71
                                                     Obs per group:
                                                                  min =     12
                                                                  avg =   12.0
                                                                  max =     12
DF method: Kenward–Roger                             DF:          min = 693.83
                                                                  avg = 709.44
                                                                  max = 736.12
                                                     F(5, 440.38)     = 449.11
Log restricted-likelihood = -678.98651               Prob > F         = 0.0000

--------------------------------------------------------------------------------------
         Congruence1 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
---------------------+----------------------------------------------------------------
           AgentType |
                 RL  |  -1.903945   .1452244   -13.11   0.000    -2.189049   -1.618842
              RL_HP  |  -1.589011    .144914   -10.97   0.000    -1.873507   -1.304515
                     |
            TrialNum |   .0107104   .0278887     0.38   0.701     -.044046    .0654668
                     |
AgentType#c.TrialNum |
                 RL  |  -.0331023   .0394406    -0.84   0.402    -.1105395     .044335
              RL_HP  |   .0052941   .0394406     0.13   0.893    -.0721431    .0827313
                     |
               _cons |    1.17516   .1025932    11.45   0.000      .973736    1.376584
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |   .0063948   .0138229      .0000924    .4423574
            var(3.AgentType) |   6.31e-10   2.70e-09      1.41e-13    2.82e-06
                  var(_cons) |   .0017977   .0054436      4.76e-06    .6795882
-----------------------------+------------------------------------------------
               var(Residual) |   .2761121   .0157751      .2468617    .3088282
------------------------------------------------------------------------------
LR test vs. linear model: chi2(3) = 0.37                  Prob > chi2 = 0.9467

Note: LR test is conservative and provided only for reference.

. 
. // 1-way effects
. contrast i.AgentType, small     // F(2, 893.19) = 203.44, p < .0001

Contrasts of marginal linear predictions

Margins: asbalanced

-----------------------------------------------------------
             |         df        ddf           F        P>F
-------------+---------------------------------------------
Congruence1  |
   AgentType |          2     746.66       98.97     0.0000
-----------------------------------------------------------

. pwcompare i.AgentType, small effects mcompare(bonf) // all p < .001

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

---------------------------
             |    Number of
             |  comparisons
-------------+-------------
Congruence1  |
   AgentType |            3
---------------------------

-------------------------------------------------------------------------------
              |                            Bonferroni           Bonferroni
              |   Contrast   Std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
Congruence1   |
    AgentType |
   RL vs DMP  |  -1.903945   .1452244   -13.11   0.000    -2.252406   -1.555484
RL_HP vs DMP  |  -1.589011    .144914   -10.97   0.000     -1.93673   -1.241291
 RL_HP vs RL  |   .3149344   .1452244     2.17   0.091    -.0334892     .663358
-------------------------------------------------------------------------------

. 
. margins i.AgentType // Presents marginal predicted means. This is represented as z-scores

Predictive margins                                         Number of obs = 852

Expression: Linear prediction, fixed portion, predict()

------------------------------------------------------------------------------
             |            Delta-method
             |     Margin   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
        DMP  |   1.212647   .0315839    38.39   0.000     1.150743     1.27455
         RL  |  -.8071564    .032979   -24.47   0.000     -.871794   -.7425188
      RL_HP  |  -.3578347   .0315839   -11.33   0.000    -.4197381   -.2959313
------------------------------------------------------------------------------

. 
. // 2-way effect
. contrast i.AgentType#c.TrialNum, small // F(2, 902.46) = 3.46, p = .0319

Contrasts of marginal linear predictions

Margins: asbalanced

-------------------------------------------------------------------
                     |         df        ddf           F        P>F
---------------------+---------------------------------------------
Congruence1          |
AgentType#c.TrialNum |          2     693.83        0.56     0.5733
-------------------------------------------------------------------

. 
. pwcompare (c.TrialNum#AgentType), mcompare(bonf) small // to get error dof

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

-----------------------------------
                     |    Number of
                     |  comparisons
---------------------+-------------
Congruence1          |
AgentType#c.TrialNum |            3
-----------------------------------

------------------------------------------------------------------------------------
                     |                                               Bonferroni
                     |   Contrast   Std. err.           df      [95% conf. interval]
---------------------+--------------------------------------------------------------
Congruence1          |
AgentType#c.TrialNum |
          RL vs DMP  |  -.0331023   .0394406         693.8     -.1277518    .0615473
       RL_HP vs DMP  |   .0052941   .0394406         693.8     -.0893554    .0999436
        RL_HP vs RL  |   .0383964   .0394406         693.8     -.0562532    .1330459
------------------------------------------------------------------------------------

. pwcompare (c.TrialNum#AgentType), effects mcompare(bonf) small

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

-----------------------------------
                     |    Number of
                     |  comparisons
---------------------+-------------
Congruence1          |
AgentType#c.TrialNum |            3
-----------------------------------

--------------------------------------------------------------------------------------
                     |                            Bonferroni           Bonferroni
                     |   Contrast   Std. err.      t    P>|t|     [95% conf. interval]
---------------------+----------------------------------------------------------------
Congruence1          |
AgentType#c.TrialNum |
          RL vs DMP  |  -.0331023   .0394406    -0.84   1.000    -.1277518    .0615473
       RL_HP vs DMP  |   .0052941   .0394406     0.13   1.000    -.0893554    .0999436
        RL_HP vs RL  |   .0383964   .0394406     0.97   0.992    -.0562532    .1330459
--------------------------------------------------------------------------------------

. // RL has more negative slope compared to DMP condition (contrast = -0.0720501), t(902.5) = -2.59, p = .029. Other comparisons are p >= .278
. 
end of do-file
