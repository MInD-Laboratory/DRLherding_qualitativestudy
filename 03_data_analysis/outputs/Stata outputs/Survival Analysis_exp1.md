
. //Survival Analysis experiment 1
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
. //Set up survivial analysis 
. stset TrialTime, failure(Success=1)

Survival-time data settings

         Failure event: Success==1
Observed time interval: (0, TrialTime]
     Exit on or before: failure

--------------------------------------------------------------------------
      1,065  total observations
          0  exclusions
--------------------------------------------------------------------------
      1,065  observations remaining, representing
        836  failures in single-record/single-failure data
  42,064.74  total analysis time at risk and under observation
                                                At risk from t =         0
                                     Earliest observed entry t =         0
                                          Last observed exit t =     90.12

. 
. graph set window fontface "Times New Roman" 

. sts graph, by(AgentType) ci failure title("") ylabel(0(0.2)1, angle(0)) ytitle("Success Probability") xlabel(0(10)100, labsize(small)) legend(order(7 "Heuristic-AA" 9 "DRL-HP-AA" 8 "DRL-AA" 1 "95% CI" 5 "95% CI" 3 "95% CI") cols(7) position(1)) graph
> region(color(white)) xtitle("Trial Time (s)")

        Failure _d: Success==1
  Analysis time _t: TrialTime

. // Determine which distribution is best for AFT
. 
. // note Congruence1 is Congruence z-scored
. histogram Congruence, normal
(bin=30, start=0, width=.03061728)

. 
. // Run this first
. frame create frame1 str32 model float(aic bic)

. foreach model in exponential loglogistic weibull lognormal ggamma  {
  2.     quietly mestreg i.AgentType##c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(`model') time
  3.     quietly estat ic
  4.     matrix S = r(S)
  5.     frame post frame1 ("`model'") (S[1,5]) (S[1, 6])
  6. }
r(198);

end of do-file

r(198);

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD65e8_000000.tmp"

. // then run this
. frame change frame1

. format aic bic %3.2f

. sort aic bic

. list

     +---------------------------------+
     |       model       aic       bic |
     |---------------------------------|
  1. | loglogistic   7305.88   7360.55 |
  2. |   lognormal   7312.14   7366.81 |
  3. |     weibull   7409.78   7464.46 |
  4. | exponential   7597.28   7646.99 |
     +---------------------------------+

. 
. // loglogistic model is best fit
. 
end of do-file

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD65e8_000000.tmp"

. frame change default

. frame drop frame1

. 
. 
. // Random-intercepts and Random-effect of Agent Type. Control for amount of decision-overlab (Congruence1 = z-scored Congruence), it's interaction, as well as TrialNum (serves as time)
. 
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(loglogistic) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -4009.4619  
Iteration 1:  Log likelihood = -3844.0926  
Iteration 2:  Log likelihood = -3758.6334  
Iteration 3:  Log likelihood =  -3724.856  
Iteration 4:  Log likelihood = -3724.6524  
Iteration 5:  Log likelihood = -3724.6523  

Refining starting values:

Grid node 0:  Log likelihood = -3727.6677

Fitting full model:

Iteration 0:  Log likelihood = -3727.6677  (not concave)
Iteration 1:  Log likelihood = -3684.7187  (not concave)
Iteration 2:  Log likelihood = -3680.1969  (not concave)
Iteration 3:  Log likelihood = -3663.3852  
Iteration 4:  Log likelihood = -3654.2764  
Iteration 5:  Log likelihood = -3643.1673  
Iteration 6:  Log likelihood = -3641.9852  
Iteration 7:  Log likelihood = -3641.9376  
Iteration 8:  Log likelihood = -3641.9376  

Mixed-effects loglogistic AFT regression        Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(6)      =     717.45
Log likelihood = -3641.9376                     Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                    RL  |   11.57594   1.902434    14.90   0.000     8.388157    15.97519
                 RL_HP  |   2.986366   .3406855     9.59   0.000     2.388019    3.734636
                        |
            Congruence1 |   .8150463   .0430054    -3.88   0.000     .7349692     .903848
                        |
AgentType#c.Congruence1 |
                    RL  |   5.309179   .8800171    10.07   0.000      3.83652    7.347124
                 RL_HP  |    1.71656   .2604756     3.56   0.000     1.274957    2.311122
                        |
               TrialNum |   .8729187   .0143812    -8.25   0.000     .8451822    .9015654
                  _cons |   23.27022   2.275839    32.18   0.000     19.21111    28.18697
------------------------+----------------------------------------------------------------
                  /logs |  -.8741971    .030848                     -.9346582   -.8137361
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .1044851   .0549414                      .0372792    .2928476
        var(3.AgentType)|   .2038554   .0656129                      .1084812    .3830805
              var(_cons)|   .1244081   .0339039                      .0729252    .2122363
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. loglogistic model: chi2(3) = 165.43           Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. 
. contrast i.AgentType    // chi2(2) = 225.50, p < .0001

Contrasts of marginal linear predictions

Margins: asbalanced

------------------------------------------------
             |         df        chi2     P>chi2
-------------+----------------------------------
_t           |
   AgentType |          2      253.48     0.0000
------------------------------------------------

. pwcompare i.AgentType, effects tratio

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

-------------------------------------------------------------------------------
              |                            Unadjusted           Unadjusted
              | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
--------------+----------------------------------------------------------------
_t            |
    AgentType |
   RL vs DMP  |   11.57594   1.902434    14.90   0.000     8.388157    15.97519
RL_HP vs DMP  |   2.986366   .3406855     9.59   0.000     2.388019    3.734636
 RL_HP vs RL  |   .2579804   .0442512    -7.90   0.000     .1843235    .3610711
-------------------------------------------------------------------------------

. 
. margins, dydx(Congruence1) pwcompare(effects)   // Congruence slope is significant (52.01 slope); z = 5.64, p < .0001
note: ignoring pwcompare options because there are no margins for making pairwise comparisons.

Average marginal effects                                 Number of obs = 1,065
Model VCE: OIM

Expression: Marginal predicted mean, predict()
dy/dx wrt:  Congruence1

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
 Congruence1 |   58.13792   10.10885     5.75   0.000     38.32494    77.95091
------------------------------------------------------------------------------

. margins i.AgentType, dydx(Congruence1)

Average marginal effects                                 Number of obs = 1,065
Model VCE: OIM

Expression: Marginal predicted mean, predict()
dy/dx wrt:  Congruence1

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
Congruence1  |
   AgentType |
        DMP  |  -4.747473   1.596847    -2.97   0.003    -7.877235    -1.61771
         RL  |   1510.334   784.9995     1.92   0.054    -28.23705    3048.905
      RL_HP  |   26.84818   14.48129     1.85   0.064    -1.534617    55.23099
------------------------------------------------------------------------------

. margins AgentType, at(Congruence1=(-1(1)1)) vsquish 

Predictive margins                                       Number of obs = 1,065
Model VCE: OIM

Expression: Marginal predicted mean, predict()
1._at: Congruence1 = -1
2._at: Congruence1 =  0
3._at: Congruence1 =  1

-------------------------------------------------------------------------------
              |            Delta-method
              |     Margin   std. err.      z    P>|z|     [95% conf. interval]
--------------+----------------------------------------------------------------
_at#AgentType |
       1#DMP  |   27.91894   3.672959     7.60   0.000     20.72007     35.1178
        1#RL  |   64.13814   5.662489    11.33   0.000     53.03987    75.23642
     1#RL_HP  |   53.78354   6.842394     7.86   0.000      40.3727    67.19439
       2#DMP  |   22.75523   2.026609    11.23   0.000     18.78315    26.72731
        2#RL  |   277.5403    43.7149     6.35   0.000     191.8607    363.2199
     2#RL_HP  |   75.24728   7.964924     9.45   0.000     59.63632    90.85824
       3#DMP  |   18.54656   1.191099    15.57   0.000     16.21205    20.88107
        3#RL  |    1200.98   361.1107     3.33   0.001     493.2159    1908.744
     3#RL_HP  |   105.2767   22.76803     4.62   0.000     60.65216    149.9012
-------------------------------------------------------------------------------

. marginsplot

Variables that uniquely identify margins: Congruence1 AgentType

. 
. // AgentType#Congruence1 interaction
. contrast i.AgentType#c.Congruence1      //chi2(2) = 101.65, p < .0001

Contrasts of marginal linear predictions

Margins: asbalanced

-----------------------------------------------------------
                        |         df        chi2     P>chi2
------------------------+----------------------------------
_t                      |
AgentType#c.Congruence1 |          2      107.08     0.0000
-----------------------------------------------------------

. 
. // Heuristic Agent
. lincom Congruence1, eform // Time-ratio = 0.79

 ( 1)  [_t]Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   .8150463   .0430054    -3.88   0.000     .7349692     .903848
------------------------------------------------------------------------------

. 
. // RL Agent
. lincom Congruence1 + 2.AgentType#c.Congruence1, eform   // Time-ratio = 4.02

 ( 1)  [_t]Congruence1 + [_t]2.AgentType#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   4.327227    .674445     9.40   0.000     3.188165    5.873252
------------------------------------------------------------------------------

. 
. // RL-HP Agent
. lincom Congruence1 + 3.AgentType#c.Congruence1, eform   // e.g., Time-ratio = 1.36

 ( 1)  [_t]Congruence1 + [_t]3.AgentType#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   1.399076    .199212     2.36   0.018     1.058377    1.849449
------------------------------------------------------------------------------

. 
. pwcompare i.AgentType#c.Congruence1, effects mcompare(bonferroni) // all p < .001

Pairwise comparisons of marginal linear predictions

Margins: asbalanced

--------------------------------------
                        |    Number of
                        |  comparisons
------------------------+-------------
_t                      |
AgentType#c.Congruence1 |            3
--------------------------------------

-----------------------------------------------------------------------------------------
                        |                            Bonferroni           Bonferroni
                        |   Contrast   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
_t                      |
AgentType#c.Congruence1 |
             RL vs DMP  |   1.669437   .1657539    10.07   0.000     1.272626    2.066249
          RL_HP vs DMP  |   .5403226   .1517428     3.56   0.001     .1770535    .9035917
           RL_HP vs RL  |  -1.129115     .21092    -5.35   0.000    -1.634053   -.6241764
-----------------------------------------------------------------------------------------

. 
. 
. predict xbhat, xb  // Get linear predictor (log scale)

. gen yhat = exp(xbhat)  // Convert back to original time scale

. twoway (lfit TrialTime Congruence if AgentType == 1, lcolor(blue) lwidth(medium)) (lfit TrialTime Congruence if AgentType == 2, lcolor(orange) lwidth(medium)) (lfit TrialTime Congruence if AgentType == 3, lcolor(green) lwidth(medium)) (scatter TrialT
> ime Congruence if AgentType == 1, mcolor(blue) msize(small)) (scatter TrialTime Congruence if AgentType == 2, mcolor(orange) msize(small)) (scatter TrialTime Congruence if AgentType == 3, mcolor(green) msize(small)), legend(order(1 "Heuristic-AA" 3 "
> DRL-HP-AA" 2 "DRL-AA") cols(9) position(1)) xtitle("Congruence") ytitle("Trial Time (s)") title("") ylabel(0(20)120)

. 
. // Check for multicollinearity and non-linearity
. gen ln_time = ln(_t)

. reg ln_time i.AgentType c.Congruence1##i.AgentType c.TrialNum

      Source |       SS           df       MS      Number of obs   =     1,065
-------------+----------------------------------   F(6, 1058)      =    127.22
       Model |   398.96928         6  66.4948799   Prob > F        =    0.0000
    Residual |  552.973491     1,058  .522659255   R-squared       =    0.4191
-------------+----------------------------------   Adj R-squared   =    0.4158
       Total |  951.942771     1,064  .894683055   Root MSE        =    .72295

-----------------------------------------------------------------------------------------
                ln_time | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                    RL  |    1.67279   .1127541    14.84   0.000     1.451543    1.894037
                 RL_HP  |   .8486125   .0902312     9.40   0.000       .67156    1.025665
                        |
            Congruence1 |  -.2569575   .0495242    -5.19   0.000    -.3541343   -.1597807
                        |
AgentType#c.Congruence1 |
                    RL  |   1.219363   .1126643    10.82   0.000     .9982919    1.440433
                 RL_HP  |   .5563198   .1249046     4.45   0.000      .311231    .8014086
                        |
               TrialNum |  -.1083251   .0157291    -6.89   0.000    -.1391889   -.0774612
                  _cons |   3.148553    .082388    38.22   0.000      2.98689    3.310215
-----------------------------------------------------------------------------------------

. estat vif

    Variable |       VIF       1/VIF  
-------------+----------------------
   AgentType |
          2  |      5.76    0.173707
          3  |      3.69    0.271249
 Congruence1 |      4.99    0.200294
   AgentType#|
          c. |
 Congruence1 |
          2  |      4.87    0.205519
          3  |      2.16    0.462125
    TrialNum |      1.01    0.991811
-------------+----------------------
    Mean VIF |      3.75

. 
. // Linear model (for quadratic LRT comparison)
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(loglogistic) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -4009.4619  
Iteration 1:  Log likelihood = -3844.0926  
Iteration 2:  Log likelihood = -3758.6334  
Iteration 3:  Log likelihood =  -3724.856  
Iteration 4:  Log likelihood = -3724.6524  
Iteration 5:  Log likelihood = -3724.6523  

Refining starting values:

Grid node 0:  Log likelihood = -3727.6677

Fitting full model:

Iteration 0:  Log likelihood = -3727.6677  (not concave)
Iteration 1:  Log likelihood = -3684.7187  (not concave)
Iteration 2:  Log likelihood = -3680.1969  (not concave)
Iteration 3:  Log likelihood = -3663.3852  
Iteration 4:  Log likelihood = -3654.2764  
Iteration 5:  Log likelihood = -3643.1673  
Iteration 6:  Log likelihood = -3641.9852  
Iteration 7:  Log likelihood = -3641.9376  
Iteration 8:  Log likelihood = -3641.9376  

Mixed-effects loglogistic AFT regression        Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(6)      =     717.45
Log likelihood = -3641.9376                     Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                    RL  |   11.57594   1.902434    14.90   0.000     8.388157    15.97519
                 RL_HP  |   2.986366   .3406855     9.59   0.000     2.388019    3.734636
                        |
            Congruence1 |   .8150463   .0430054    -3.88   0.000     .7349692     .903848
                        |
AgentType#c.Congruence1 |
                    RL  |   5.309179   .8800171    10.07   0.000      3.83652    7.347124
                 RL_HP  |    1.71656   .2604756     3.56   0.000     1.274957    2.311122
                        |
               TrialNum |   .8729187   .0143812    -8.25   0.000     .8451822    .9015654
                  _cons |   23.27022   2.275839    32.18   0.000     19.21111    28.18697
------------------------+----------------------------------------------------------------
                  /logs |  -.8741971    .030848                     -.9346582   -.8137361
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .1044851   .0549414                      .0372792    .2928476
        var(3.AgentType)|   .2038554   .0656129                      .1084812    .3830805
              var(_cons)|   .1244081   .0339039                      .0729252    .2122363
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. loglogistic model: chi2(3) = 165.43           Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m1

. 
. // Check if Quadratic Term improves model fit.
. mestreg i.AgentType c.Congruence1 c.Congruence1#c.Congruence1 ///
>     i.AgentType#c.Congruence1 i.AgentType#c.Congruence1#c.Congruence1 c.TrialNum ///
>     || PartID: i.AgentType, distribution(loglogistic) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -3993.0724  
Iteration 1:  Log likelihood = -3804.1044  
Iteration 2:  Log likelihood = -3740.5259  
Iteration 3:  Log likelihood = -3698.5882  
Iteration 4:  Log likelihood = -3698.0877  
Iteration 5:  Log likelihood =  -3698.085  
Iteration 6:  Log likelihood =  -3698.085  

Refining starting values:

Grid node 0:  Log likelihood = -3710.1902

Fitting full model:

Iteration 0:  Log likelihood = -3710.1902  (not concave)
Iteration 1:  Log likelihood = -3666.2587  (not concave)
Iteration 2:  Log likelihood = -3657.5679  (not concave)
Iteration 3:  Log likelihood = -3641.6096  
Iteration 4:  Log likelihood = -3632.6417  
Iteration 5:  Log likelihood = -3622.2081  
Iteration 6:  Log likelihood = -3620.3531  
Iteration 7:  Log likelihood = -3620.2748  
Iteration 8:  Log likelihood = -3620.2745  

Mixed-effects loglogistic AFT regression        Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(9)      =     809.55
Log likelihood = -3620.2745                     Prob > chi2       =     0.0000
-------------------------------------------------------------------------------------------------------
                                   _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
--------------------------------------+----------------------------------------------------------------
                            AgentType |
                                  RL  |   9.332486   2.146303     9.71   0.000     5.946158    14.64732
                               RL_HP  |   3.188224   .3706323     9.97   0.000     2.538612    4.004067
                                      |
                          Congruence1 |   .8782446   .1190009    -0.96   0.338      .673409    1.145387
                                      |
          c.Congruence1#c.Congruence1 |   .9727817   .0509249    -0.53   0.598     .8779204    1.077893
                                      |
              AgentType#c.Congruence1 |
                                  RL  |   2.493149    1.30338     1.75   0.081     .8948563    6.946136
                               RL_HP  |   .6859301   .1539569    -1.68   0.093     .4418021    1.064957
                                      |
AgentType#c.Congruence1#c.Congruence1 |
                                  RL  |   .6882481   .2040103    -1.26   0.208     .3849746    1.230433
                               RL_HP  |   .2588661   .0554658    -6.31   0.000     .1700956    .3939647
                                      |
                             TrialNum |   .8697518   .0139954    -8.67   0.000     .8427494    .8976193
                                _cons |   22.72163   2.415883    29.38   0.000     18.44741    27.98619
--------------------------------------+----------------------------------------------------------------
                                /logs |  -.8999863   .0309337                     -.9606153   -.8393573
--------------------------------------+----------------------------------------------------------------
PartID                                |
                      var(2.AgentType)|   .1032884   .0530979                      .0377112    .2828996
                      var(3.AgentType)|   .1616175   .0568036                      .0811553    .3218547
                            var(_cons)|   .1258294   .0338399                      .0742787    .2131572
-------------------------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. loglogistic model: chi2(3) = 155.62           Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m2

. 
. lrtest m1 m2    // lr-test chi2(3) = 42.49, p < .0001

Likelihood-ratio test
Assumption: m1 nested within m2

 LR chi2(3) =  43.33
Prob > chi2 = 0.0000

.         
. // Test for interaction between quadratic term and AA type
. contrast i.AgentType#c.Congruence1#c.Congruence1 // chi2(2) = 38.96, p < .0001

Contrasts of marginal linear predictions

Margins: asbalanced

-------------------------------------------------------------------------
                                      |         df        chi2     P>chi2
--------------------------------------+----------------------------------
_t                                    |
AgentType#c.Congruence1#c.Congruence1 |          2       40.78     0.0000
-------------------------------------------------------------------------

. 
. // Get quadratic coefficients for each condition
. lincom c.Congruence1#c.Congruence1      // Heuristic -0.0304907, z = -0.60, p = .550

 ( 1)  [_t]c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.0275956   .0523498    -0.53   0.598    -.1301994    .0750081
------------------------------------------------------------------------------

. lincom c.Congruence1#c.Congruence1 + 2.AgentType#c.Congruence1#c.Congruence1 // DRL-AA Coefficient -0.3854438, z = -1.29, p = .198

 ( 1)  [_t]c.Congruence1#c.Congruence1 + [_t]2.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.4012015   .2925967    -1.37   0.170    -.9746804    .1722774
------------------------------------------------------------------------------

. lincom c.Congruence1#c.Congruence1 + 3.AgentType#c.Congruence1#c.Congruence1 // DRL-HP-AA Coefficient = -1.387524, z = -6.49, p < .0001

 ( 1)  [_t]c.Congruence1#c.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   -1.37904   .2077093    -6.64   0.000    -1.786143    -.971937
------------------------------------------------------------------------------

. 
. 
. // Significant effect of quadratic term for RL_HP compared to baseline (Heuristic) (z = -6.17, p < .0001).
. lincom 3.AgentType#c.Congruence1#c.Congruence1 - 1.AgentType#c.Congruence1#c.Congruence1

 ( 1)  - [_t]1b.AgentType#co.Congruence1#co.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -1.351444   .2142643    -6.31   0.000    -1.771395   -.9314939
------------------------------------------------------------------------------

. 
. // Significant effect of quadratic term for RL_HP compared to DRL-AA (z = -2.73, p = .006).
. lincom 3.AgentType#c.Congruence1#c.Congruence1 - 2.AgentType#c.Congruence1#c.Congruence1

 ( 1)  - [_t]2.AgentType#c.Congruence1#c.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.9778383    .358472    -2.73   0.006     -1.68043   -.2752462
------------------------------------------------------------------------------

. 
. lincom 2.AgentType#c.Congruence1#c.Congruence1 - 1.AgentType#c.Congruence1#c.Congruence1 // p = .241

 ( 1)  - [_t]1b.AgentType#co.Congruence1#co.Congruence1 + [_t]2.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.3736059   .2964197    -1.26   0.208    -.9545779     .207366
------------------------------------------------------------------------------

. 
. 
. 
end of do-file
