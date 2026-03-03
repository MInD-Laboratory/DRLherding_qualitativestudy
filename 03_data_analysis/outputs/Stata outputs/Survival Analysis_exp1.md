
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

. sts graph, by(AgentType) ci failure title("") ylabel(0(0.2)1, angle(0)) ytitle("Success Probability") xlabel(0(10)100, labsize(small)) legend(order(7 "Heuristic-AA" 9 "DRL-HP-AA
> " 8 "DRL-AA" 1 "95% CI" 5 "95% CI" 3 "95% CI") cols(7) position(1)) graphregion(color(white)) xtitle("Trial Time (s)")

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

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD10a30_000000.tmp"

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
. // lognormal model is best fit (AIC = 7330.74; BIC = 7375.48)
. 
. frame change default

. frame drop frame1

. 
. 
. // Random-intercepts and Random-effect of Agent Type. Control for amount of decision-overlab (Congruence1 = z-scored Congruence), it's interaction, as well as TrialNum (serves a
> s time)
. 
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -3881.0353  
Iteration 1:  Log likelihood = -3843.5638  
Iteration 2:  Log likelihood =  -3723.191  
Iteration 3:  Log likelihood = -3722.0378  
Iteration 4:  Log likelihood = -3722.0351  
Iteration 5:  Log likelihood = -3722.0351  

Refining starting values:

Grid node 0:  Log likelihood = -3728.5593

Fitting full model:

Iteration 0:  Log likelihood = -3728.5593  (not concave)
Iteration 1:  Log likelihood = -3684.5981  (not concave)
Iteration 2:  Log likelihood =  -3663.222  
Iteration 3:  Log likelihood = -3648.7462  
Iteration 4:  Log likelihood = -3645.2204  
Iteration 5:  Log likelihood = -3645.0689  
Iteration 6:  Log likelihood =  -3645.068  
Iteration 7:  Log likelihood =  -3645.068  

Mixed-effects lognormal AFT regression          Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(6)      =     648.45
Log likelihood = -3645.068                      Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                    RL  |   10.17026   1.668474    14.14   0.000     7.373758    14.02734
                 RL_HP  |    2.72472   .2971662     9.19   0.000     2.200328    3.374089
                        |
            Congruence1 |    .792781   .0428796    -4.29   0.000     .7130398    .8814398
                        |
AgentType#c.Congruence1 |
                    RL  |   5.070951    .843635     9.76   0.000     3.659976    7.025878
                 RL_HP  |   1.715178   .2412255     3.84   0.000     1.301952    2.259559
                        |
               TrialNum |   .8708294   .0146913    -8.20   0.000     .8425058    .9001051
                  _cons |   25.08758    2.46956    32.74   0.000     20.68563    30.42629
------------------------+----------------------------------------------------------------
                  /logs |  -.3041865   .0270945                     -.3572908   -.2510822
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .1120586   .0581635                      .0405166    .3099254
        var(3.AgentType)|   .1574251   .0582977                      .0761828    .3253052
              var(_cons)|   .1343576    .035057                      .0805683    .2240579
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. lognormal model: chi2(3) = 153.93             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. 
. contrast i.AgentType    // chi2(2) = 225.50, p < .0001

Contrasts of marginal linear predictions

Margins: asbalanced

------------------------------------------------
             |         df        chi2     P>chi2
-------------+----------------------------------
_t           |
   AgentType |          2      225.50     0.0000
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
   RL vs DMP  |   10.17026   1.668474    14.14   0.000     7.373758    14.02734
RL_HP vs DMP  |    2.72472   .2971662     9.19   0.000     2.200328    3.374089
 RL_HP vs RL  |   .2679106   .0446093    -7.91   0.000     .1933115    .3712975
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
 Congruence1 |   52.01784   9.216568     5.64   0.000      33.9537    70.08198
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
        DMP  |  -5.646968   1.766071    -3.20   0.001    -9.108403   -2.185532
         RL  |   1160.775   597.1165     1.94   0.052    -9.551379    2331.102
      RL_HP  |   22.58489   11.83834     1.91   0.056    -.6178229     45.7876
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
       1#DMP  |   29.90426   3.957045     7.56   0.000      22.1486    37.65993
        1#RL  |   63.43208   5.759146    11.01   0.000     52.14436     74.7198
     1#RL_HP  |   51.39611   6.035525     8.52   0.000     39.56669    63.22552
       2#DMP  |   23.70753   2.103853    11.27   0.000     19.58406    27.83101
        2#RL  |   255.0067   40.21775     6.34   0.000     176.1814     333.832
     2#RL_HP  |   69.88641   6.928912    10.09   0.000     56.30599    83.46682
       3#DMP  |   18.79488   1.202229    15.63   0.000     16.43855    21.15121
        3#RL  |   1025.166   307.8761     3.33   0.001     421.7401    1628.592
     3#RL_HP  |   95.02879   18.92005     5.02   0.000     57.94618    132.1114
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
AgentType#c.Congruence1 |          2      101.65     0.0000
-----------------------------------------------------------

. 
. // Heuristic Agent
. lincom Congruence1, eform // Time-ratio = 0.79

 ( 1)  [_t]Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |    .792781   .0428796    -4.29   0.000     .7130398    .8814398
------------------------------------------------------------------------------

. 
. // RL Agent
. lincom Congruence1 + 2.AgentType#c.Congruence1, eform   // Time-ratio = 4.02

 ( 1)  [_t]Congruence1 + [_t]2.AgentType#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   4.020154   .6272458     8.92   0.000     2.960968    5.458228
------------------------------------------------------------------------------

. 
. // RL-HP Agent
. lincom Congruence1 + 3.AgentType#c.Congruence1, eform   // e.g., Time-ratio = 1.36

 ( 1)  [_t]Congruence1 + [_t]3.AgentType#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   1.359761    .176692     2.36   0.018     1.054034    1.754166
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
             RL vs DMP  |   1.623528   .1663662     9.76   0.000     1.225251    2.021806
          RL_HP vs DMP  |   .5395171   .1406416     3.84   0.000     .2028239    .8762103
           RL_HP vs RL  |  -1.084011   .2027144    -5.35   0.000    -1.569306   -.5987172
-----------------------------------------------------------------------------------------

. 
. 
. predict xbhat, xb  // Get linear predictor (log scale)

. gen yhat = exp(xbhat)  // Convert back to original time scale

. twoway (lfit TrialTime Congruence if AgentType == 1, lcolor(blue) lwidth(medium)) (lfit TrialTime Congruence if AgentType == 2, lcolor(orange) lwidth(medium)) (lfit TrialTime Co
> ngruence if AgentType == 3, lcolor(green) lwidth(medium)) (scatter TrialTime Congruence if AgentType == 1, mcolor(blue) msize(small)) (scatter TrialTime Congruence if AgentType 
> == 2, mcolor(orange) msize(small)) (scatter TrialTime Congruence if AgentType == 3, mcolor(green) msize(small)), legend(order(1 "Heuristic-AA" 3 "DRL-HP-AA" 2 "DRL-AA") cols(9) 
> position(1)) xtitle("Congruence") ytitle("Trial Time (s)") title("") ylabel(0(20)120)

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
. // Original Model
. mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -3881.0353  
Iteration 1:  Log likelihood = -3843.5638  
Iteration 2:  Log likelihood =  -3723.191  
Iteration 3:  Log likelihood = -3722.0378  
Iteration 4:  Log likelihood = -3722.0351  
Iteration 5:  Log likelihood = -3722.0351  

Refining starting values:

Grid node 0:  Log likelihood = -3728.5593

Fitting full model:

Iteration 0:  Log likelihood = -3728.5593  (not concave)
Iteration 1:  Log likelihood = -3684.5981  (not concave)
Iteration 2:  Log likelihood =  -3663.222  
Iteration 3:  Log likelihood = -3648.7462  
Iteration 4:  Log likelihood = -3645.2204  
Iteration 5:  Log likelihood = -3645.0689  
Iteration 6:  Log likelihood =  -3645.068  
Iteration 7:  Log likelihood =  -3645.068  

Mixed-effects lognormal AFT regression          Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(6)      =     648.45
Log likelihood = -3645.068                      Prob > chi2       =     0.0000
-----------------------------------------------------------------------------------------
                     _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
------------------------+----------------------------------------------------------------
              AgentType |
                    RL  |   10.17026   1.668474    14.14   0.000     7.373758    14.02734
                 RL_HP  |    2.72472   .2971662     9.19   0.000     2.200328    3.374089
                        |
            Congruence1 |    .792781   .0428796    -4.29   0.000     .7130398    .8814398
                        |
AgentType#c.Congruence1 |
                    RL  |   5.070951    .843635     9.76   0.000     3.659976    7.025878
                 RL_HP  |   1.715178   .2412255     3.84   0.000     1.301952    2.259559
                        |
               TrialNum |   .8708294   .0146913    -8.20   0.000     .8425058    .9001051
                  _cons |   25.08758    2.46956    32.74   0.000     20.68563    30.42629
------------------------+----------------------------------------------------------------
                  /logs |  -.3041865   .0270945                     -.3572908   -.2510822
------------------------+----------------------------------------------------------------
PartID                  |
        var(2.AgentType)|   .1120586   .0581635                      .0405166    .3099254
        var(3.AgentType)|   .1574251   .0582977                      .0761828    .3253052
              var(_cons)|   .1343576    .035057                      .0805683    .2240579
-----------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. lognormal model: chi2(3) = 153.93             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m1

. 
. // Check if Quadratic Term improves model fit.
. mestreg i.AgentType c.Congruence1 c.Congruence1#c.Congruence1 ///
>     i.AgentType#c.Congruence1 i.AgentType#c.Congruence1#c.Congruence1 c.TrialNum ///
>     || PartID: i.AgentType, distribution(lognormal) time tratio

        Failure _d: Success==1
  Analysis time _t: TrialTime

Fitting fixed-effects model:

Iteration 0:  Log likelihood = -3844.6214  
Iteration 1:  Log likelihood = -3790.2518  
Iteration 2:  Log likelihood = -3698.0463  
Iteration 3:  Log likelihood = -3697.6253  
Iteration 4:  Log likelihood =  -3697.625  

Refining starting values:

Grid node 0:  Log likelihood = -3712.0613

Fitting full model:

Iteration 0:  Log likelihood = -3712.0613  (not concave)
Iteration 1:  Log likelihood = -3667.5992  (not concave)
Iteration 2:  Log likelihood = -3645.9438  
Iteration 3:  Log likelihood = -3631.0294  
Iteration 4:  Log likelihood = -3624.0076  
Iteration 5:  Log likelihood = -3623.8225  
Iteration 6:  Log likelihood = -3623.8223  

Mixed-effects lognormal AFT regression          Number of obs     =      1,065
Group variable: PartID                          Number of groups  =         71

                                                Obs per group:
                                                              min =         15
                                                              avg =       15.0
                                                              max =         15

Integration method: mvaghermite                 Integration pts.  =          7

                                                Wald chi2(9)      =     732.77
Log likelihood = -3623.8223                     Prob > chi2       =     0.0000
-------------------------------------------------------------------------------------------------------
                                   _t | Time ratio   Std. err.      z    P>|z|     [95% conf. interval]
--------------------------------------+----------------------------------------------------------------
                            AgentType |
                                  RL  |   8.357412   1.874505     9.47   0.000     5.384602    12.97149
                               RL_HP  |   2.900442   .3223281     9.58   0.000     2.332757    3.606274
                                      |
                          Congruence1 |   .8584752   .1114511    -1.18   0.240     .6656117    1.107222
                                      |
          c.Congruence1#c.Congruence1 |   .9699695   .0495296    -0.60   0.550     .8775929     1.07207
                                      |
              AgentType#c.Congruence1 |
                                  RL  |    2.46948   1.285179     1.74   0.082     .8904696    6.848446
                               RL_HP  |   .6770059   .1517768    -1.74   0.082     .4362777    1.050563
                                      |
AgentType#c.Congruence1#c.Congruence1 |
                                  RL  |   .7012063   .2122411    -1.17   0.241     .3874397    1.269076
                               RL_HP  |   .2574235   .0566202    -6.17   0.000     .1672733     .396159
                                      |
                             TrialNum |   .8666679   .0143031    -8.67   0.000      .839083    .8951598
                                _cons |   24.61128   2.540697    31.03   0.000     20.10306     30.1305
--------------------------------------+----------------------------------------------------------------
                                /logs |  -.3282375   .0271766                     -.3815027   -.2749723
--------------------------------------+----------------------------------------------------------------
PartID                                |
                      var(2.AgentType)|   .1107426   .0562709                      .0409072    .2997989
                      var(3.AgentType)|   .1200733   .0505746                      .0525923    .2741387
                            var(_cons)|   .1353654   .0346902                      .0819162    .2236896
-------------------------------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation to time ratios.
Note: _cons estimates baseline time (conditional on zero random effects).
LR test vs. lognormal model: chi2(3) = 147.61             Prob > chi2 = 0.0000

Note: LR test is conservative and provided only for reference.

. estimates store m2

. 
. lrtest m1 m2    // lr-test chi2(3) = 42.49, p < .0001

Likelihood-ratio test
Assumption: m1 nested within m2

 LR chi2(3) =  42.49
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
AgentType#c.Congruence1#c.Congruence1 |          2       38.96     0.0000
-------------------------------------------------------------------------

. 
. // Get quadratic coefficients for each condition
. lincom c.Congruence1#c.Congruence1      // Heuristic -0.0304907, z = -0.60, p = .550

 ( 1)  [_t]c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.0304907   .0510631    -0.60   0.550    -.1305725    .0695911
------------------------------------------------------------------------------

. lincom c.Congruence1#c.Congruence1 + 2.AgentType#c.Congruence1#c.Congruence1 // DRL-AA Coefficient -0.3854438, z = -1.29, p = .198

 ( 1)  [_t]c.Congruence1#c.Congruence1 + [_t]2.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.3854438   .2992745    -1.29   0.198     -.972011    .2011233
------------------------------------------------------------------------------

. lincom c.Congruence1#c.Congruence1 + 3.AgentType#c.Congruence1#c.Congruence1 // DRL-HP-AA Coefficient = -1.387524, z = -6.49, p < .0001

 ( 1)  [_t]c.Congruence1#c.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -1.387524   .2139523    -6.49   0.000    -1.806862   -.9681847
------------------------------------------------------------------------------

. 
. 
. // Significant effect of quadratic term for RL_HP compared to baseline (Heuristic) (z = -6.17, p < .0001).
. lincom 3.AgentType#c.Congruence1#c.Congruence1 - 1.AgentType#c.Congruence1#c.Congruence1

 ( 1)  - [_t]1b.AgentType#co.Congruence1#co.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -1.357033   .2199496    -6.17   0.000    -1.788126   -.9259396
------------------------------------------------------------------------------

. 
. // Significant effect of quadratic term for RL_HP compared to DRL-AA (z = -2.73, p = .006).
. lincom 3.AgentType#c.Congruence1#c.Congruence1 - 2.AgentType#c.Congruence1#c.Congruence1

 ( 1)  - [_t]2.AgentType#c.Congruence1#c.Congruence1 + [_t]3.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |   -1.00208   .3674671    -2.73   0.006    -1.722302   -.2818574
------------------------------------------------------------------------------

. 
. lincom 2.AgentType#c.Congruence1#c.Congruence1 - 1.AgentType#c.Congruence1#c.Congruence1 // p = .241

 ( 1)  - [_t]1b.AgentType#co.Congruence1#co.Congruence1 + [_t]2.AgentType#c.Congruence1#c.Congruence1 = 0

------------------------------------------------------------------------------
          _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         (1) |  -.3549531     .30268    -1.17   0.241     -.948195    .2382887
------------------------------------------------------------------------------

. 
end of do-file
