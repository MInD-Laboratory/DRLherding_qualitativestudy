
. //Survival Analysis Experiment 2
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

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STDcac4_000000.tmp"

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
end of do-file
