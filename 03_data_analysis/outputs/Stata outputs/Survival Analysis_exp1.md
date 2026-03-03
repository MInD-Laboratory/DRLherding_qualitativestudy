
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

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD11c34_000000.tmp"

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
end of do-file

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD11c34_000000.tmp"

. // lognormal model is best fit (AIC = 7330.74; BIC = 7375.48)
. 
. frame change default

. frame drop frame1

. 
end of do-file

. do "C:\Users\MQ2019~1\AppData\Local\Temp\STD11c34_000000.tmp"

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
end of do-file
