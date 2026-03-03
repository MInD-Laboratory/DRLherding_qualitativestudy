
. // Survival Analysis Experiment 2
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
. //Set up survivial analysis 
. stset TrialTime, failure(Success=1)

Survival-time data settings

         Failure event: Success==1
Observed time interval: (0, TrialTime]
     Exit on or before: failure

--------------------------------------------------------------------------
        649  total observations
          0  exclusions
--------------------------------------------------------------------------
        649  observations remaining, representing
        551  failures in single-record/single-failure data
  32,909.98  total analysis time at risk and under observation
                                                At risk from t =         0
                                     Earliest observed entry t =         0
                                          Last observed exit t =      90.1

. 
. // Determine which distribution is best for AFT
. 
. // note Congruence1 is Congruence z-scored
. histogram Congruence, normal
(bin=25, start=0, width=.01983651)

. 
. // Run this first. Could not fit model with AgentType as random slope so removed.
. frame create frame2 str32 model float(aic bic)

. foreach model in exponential loglogistic weibull lognormal ggamma  {
  2.     quietly mestreg AgentType##c.Congruence1 c.TrialNum || PartID:, distribution(`model') time
  3.     quietly estat ic
  4.     matrix S = r(S)
  5.     frame post frame2 ("`model'") (S[1,5]) (S[1, 6])
  6. }
r(198);

end of do-file

r(198);

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD5864_000000.tmp"

. // Then run this
. frame change frame2

. format aic bic %3.2f

. sort aic bic

. list

     +---------------------------------+
     |       model       aic       bic |
     |---------------------------------|
  1. |   lognormal   5291.53   5322.85 |
  2. | loglogistic   5301.23   5332.56 |
  3. |     weibull   5309.14   5340.46 |
  4. | exponential   5479.35   5506.21 |
     +---------------------------------+

. 
. // lognormal model is best fit. (AIC = 5291.53, BIC = 5322.85)
. 
. frame change default

. frame drop frame2

. 
. // Fit same model as in Experiment 1.
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -2781.0496  
Iteration 1:  Log likelihood = -2719.3101  
Iteration 2:  Log likelihood = -2715.7232  
Iteration 3:  Log likelihood = -2715.7177  
Iteration 4:  Log likelihood = -2715.7177  

Refining starting values:

Grid node 0:  Log likelihood = -2690.0156

Fitting full model:

Iteration 0:  Log likelihood = -2690.0156  (not concave)
Iteration 1:  Log likelihood =  -2673.938  (not concave)
Iteration 2:  Log likelihood = -2662.8113  (not concave)
Iteration 3:  Log likelihood = -2658.9231  
Iteration 4:  Log likelihood = -2642.0308  
Iteration 5:  Log likelihood = -2638.6527  
Iteration 6:  Log likelihood = -2638.3393  
Iteration 7:  Log likelihood = -2638.3332  
Iteration 8:  Log likelihood = -2638.3332  

Mixed-effects lognormal AFT regression          Number of obs     =        649
Group variable: PartID                          Number of groups  =         37

                                                Obs per group:
                                                              min =          1
                                                              avg =       17.5
                                                              max =         18

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(4)      =     100.96
Log likelihood = -2638.3332                     Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                 RL_HP  |   .6634781   .0526134    -5.17   0.000     .5679719    .7750439
            Congruence1 |   1.357687    .076875     5.40   0.000     1.215075    1.517038
                        |
AgentType#c.Congruence1 |
                 RL_HP  |   .8551401   .0659996    -2.03   0.043     .7350919    .9947935
                        |
               TrialNum |   .9201172   .0103012    -7.44   0.000     .9001472    .9405302
                  _cons |   80.66761   8.963764    39.51   0.000     64.88046    100.2962
------------------------+----------------------------------------------------------------
                  /logs |  -.3382705   .0319883                     -.4009663   -.2755746
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .0280115   .0344548                      .0025139     .312129
              var(_cons)|   .2296137   .0668525                      .1297683    .4062813
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. lognormal model: chi2(2) = 154.77             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. 
. pwcompare i.AgentType, effects  // z = -5.17, p < .0001

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

------------------------------------------------------------------------------
             |                            Unadjusted           Unadjusted
             |   Contrast   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
_t           |
   AgentType |
RL_HP vs RL  |  -.4102595   .0792994    -5.17   0.000    -.5656834   -.2548356
------------------------------------------------------------------------------

. margins, dydx(Congruence1) pwcompare(effects)   // Congruence slope is significant (14.75 slope); z = 5.08, p < .0001
note: ignoring pwcompare options because there are no margins for making pairwise comparisons.

Average marginal effects                                   Number of obs = 649
Model VCE: OIM

Expression: Marginal predicted mean, predict()
dy/dx wrt:  Congruence1

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
 Congruence1 |   14.75306   2.904008     5.08   0.000     9.061304    20.44481
------------------------------------------------------------------------------

. 
. 
. // AgentType#Congruence1 interaction
. contrast i.AgentType#c.Congruence1      //chi2(1) = 4.11, p = .0426

Contrasts of marginal linear predictions

Margins: asbalanced

-----------------------------------------------------------
                        |         df        chi2     P>chi2
------------------------+----------------------------------
_t                      |
AgentType#c.Congruence1 |          1        4.11     0.0426
-----------------------------------------------------------

. 
. margins i.AgentType, dydx(Congruence1)

Average marginal effects                                   Number of obs = 649
Model VCE: OIM

Expression: Marginal predicted mean, predict()
dy/dx wrt:  Congruence1

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
Congruence1  |
   AgentType |
         RL  |   25.33044   6.395149     3.96   0.000     12.79618     37.8647
      RL_HP  |   8.013485   2.777106     2.89   0.004     2.570457    13.45651
------------------------------------------------------------------------------

. pwcompare i.AgentType#c.Congruence1, effects mcompare(bonferroni)

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

note: option bonferroni ignored since there is only one comparison
-----------------------------------------------------------------------------------------
                        |                            Unadjusted           Unadjusted
                        |   Contrast   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
_t                      |
AgentType#c.Congruence1 |
           RL_HP vs RL  |  -.1564899   .0771799    -2.03   0.043    -.3077598   -.0052201
-----------------------------------------------------------------------------------------

. 
. // RL_HP slope is -0.156 less than RL (z = -2.03, p = 0.043)
. 
. // Check for multicollinearity and non-linearity
. gen ln_time = ln(_t)

. reg ln_time i.AgentType c.Congruence1##i.AgentType c.TrialNum

      Source |       SS           df       MS      Number of obs   =       649
-------------+----------------------------------   F(4, 644)       =     26.75
       Model |  62.7409808         4  15.6852452   Prob > F        =    0.0000
    Residual |    377.6787       644  .586457609   R-squared       =    0.1425
-------------+----------------------------------   Adj R-squared   =    0.1371
       Total |  440.419681       648  .679660002   Root MSE        =    .76581

-----------------------------------------------------------------------------------------
                ln_time | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                 RL_HP  |  -.4445631   .0747459    -5.95   0.000    -.5913382    -.297788
            Congruence1 |   .4082362   .0521208     7.83   0.000      .305889    .5105834
                        |
AgentType#c.Congruence1 |
                 RL_HP  |  -.2700581   .0747998    -3.61   0.000    -.4169391   -.1231771
                        |
               TrialNum |  -.0649316   .0116477    -5.57   0.000    -.0878036   -.0420595
                  _cons |   4.270583   .0778353    54.87   0.000     4.117741    4.423425
-----------------------------------------------------------------------------------------

. estat vif

    Variable |       VIF       1/VIF  
-------------+----------------------
 2.AgentType |      1.55    0.646961
 Congruence1 |      3.00    0.333150
   AgentType#|
          c. |
 Congruence1 |
          2  |      2.49    0.402273
    TrialNum |      1.00    0.996941
-------------+----------------------
    Mean VIF |      2.01

. 
. // Original Model
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -2781.0496  
Iteration 1:  Log likelihood = -2719.3101  
Iteration 2:  Log likelihood = -2715.7232  
Iteration 3:  Log likelihood = -2715.7177  
Iteration 4:  Log likelihood = -2715.7177  

Refining starting values:

Grid node 0:  Log likelihood = -2690.0156

Fitting full model:

Iteration 0:  Log likelihood = -2690.0156  (not concave)
Iteration 1:  Log likelihood =  -2673.938  (not concave)
Iteration 2:  Log likelihood = -2662.8113  (not concave)
Iteration 3:  Log likelihood = -2658.9231  
Iteration 4:  Log likelihood = -2642.0308  
Iteration 5:  Log likelihood = -2638.6527  
Iteration 6:  Log likelihood = -2638.3393  
Iteration 7:  Log likelihood = -2638.3332  
Iteration 8:  Log likelihood = -2638.3332  

Mixed-effects lognormal AFT regression          Number of obs     =        649
Group variable: PartID                          Number of groups  =         37

                                                Obs per group:
                                                              min =          1
                                                              avg =       17.5
                                                              max =         18

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(4)      =     100.96
Log likelihood = -2638.3332                     Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                 RL_HP  |   .6634781   .0526134    -5.17   0.000     .5679719    .7750439
            Congruence1 |   1.357687    .076875     5.40   0.000     1.215075    1.517038
                        |
AgentType#c.Congruence1 |
                 RL_HP  |   .8551401   .0659996    -2.03   0.043     .7350919    .9947935
                        |
               TrialNum |   .9201172   .0103012    -7.44   0.000     .9001472    .9405302
                  _cons |   80.66761   8.963764    39.51   0.000     64.88046    100.2962
------------------------+----------------------------------------------------------------
                  /logs |  -.3382705   .0319883                     -.4009663   -.2755746
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .0280115   .0344548                      .0025139     .312129
              var(_cons)|   .2296137   .0668525                      .1297683    .4062813
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. lognormal model: chi2(2) = 154.77             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m1

. 
. // Check if Quadratic Term improves model fit.
. mestreg i.AgentType c.Congruence1 c.Congruence1#c.Congruence1 ///
>     i.AgentType#c.Congruence1 i.AgentType#c.Congruence1#c.Congruence1 c.TrialNum ///
>     || PartID: i.AgentType, distribution(lognormal) time

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -2746.9655  
Iteration 1:  Log likelihood = -2686.5869  
Iteration 2:  Log likelihood = -2684.9685  
Iteration 3:  Log likelihood = -2684.9633  
Iteration 4:  Log likelihood = -2684.9633  

Refining starting values:

Grid node 0:  Log likelihood = -2665.9853

Fitting full model:

Iteration 0:  Log likelihood = -2665.9853  (not concave)
Iteration 1:  Log likelihood = -2632.0908  
Iteration 2:  Log likelihood = -2614.0745  
Iteration 3:  Log likelihood = -2610.9545  
Iteration 4:  Log likelihood = -2610.6921  
Iteration 5:  Log likelihood = -2610.6899  
Iteration 6:  Log likelihood = -2610.6899  

Mixed-effects lognormal AFT regression          Number of obs     =        649
Group variable: PartID                          Number of groups  =         37

                                                Obs per group:
                                                              min =          1
                                                              avg =       17.5
                                                              max =         18

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(6)      =     168.50
Log likelihood = -2610.6899                     Prob > chi2       =     0.0000
-------------------------------------------------------------------------------------------------------
                                   _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
--------------------------------------+----------------------------------------------------------------
                            AgentType |
                               RL_HP  |  -.5007031   .0806668    -6.21   0.000    -.6588072    -.342599
                          Congruence1 |   .1287699   .0623328     2.07   0.039     .0065999    .2509398
                                      |
          c.Congruence1#c.Congruence1 |  -.2343226   .0427986    -5.48   0.000    -.3182062   -.1504389
                                      |
              AgentType#c.Congruence1 |
                               RL_HP  |   .2710423   .0917196     2.96   0.003     .0912752    .4508093
                                      |
AgentType#c.Congruence1#c.Congruence1 |
                               RL_HP  |   .0433014   .0561464     0.77   0.441    -.0667435    .1533464
                                      |
                             TrialNum |  -.0807329    .010606    -7.61   0.000    -.1015202   -.0599455
                                _cons |   4.504002   .1070114    42.09   0.000     4.294263     4.71374
--------------------------------------+----------------------------------------------------------------
                                /logs |  -.3926475   .0321238                     -.4556091    -.329686
--------------------------------------+----------------------------------------------------------------
PartID                                |
                      var(2.AgentType)|   .0366185   .0327965                      .0063291     .211865
                            var(_cons)|   .1994546   .0576761                      .1131626    .3515484
-------------------------------------------------------------------------------------------------------
LR test vs. lognormal model: chi2(2) = 148.55             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m2

. 
. lrtest m1 m2    // lr-test chi2(2) = 55.29, p < .0001

Likelihood-ratio test
Assumption: m1 nested within m2

 LR chi2(2) =  55.29
Prob > chi2 = 0.0000

. 
. // Test for interaction between quadratic term and AA type
. contrast i.AgentType#c.Congruence1#c.Congruence1 // chi2(1) = 0.59, p = .4406

Contrasts of marginal linear predictions

Margins: asbalanced

-------------------------------------------------------------------------
                                      |         df        chi2     P>chi2
--------------------------------------+----------------------------------
_t                                    |
AgentType#c.Congruence1#c.Congruence1 |          1        0.59     0.4406
-------------------------------------------------------------------------

. 
end of do-file
