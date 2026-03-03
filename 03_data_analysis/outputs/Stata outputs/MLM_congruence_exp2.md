

. //// Mixed effects model for congrunce_ Experiment2
> clear all

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

. // Exclude practice trial from all analyses
. keep if TrialNum != 1
(73 observations deleted)

. 
. histogram Congruence
(bin=24, start=0, width=.02066303)

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
Iteration 0:  Log likelihood = -687.16577  
Iteration 1:  Log likelihood = -686.75943  
Iteration 2:  Log likelihood = -686.72955  
Iteration 3:  Log likelihood = -686.72693  
Iteration 4:  Log likelihood = -686.72676  
Iteration 5:  Log likelihood = -686.72676  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    576
Group variable: PartID                               Number of groups =     36
                                                     Obs per group:
                                                                  min =     16
                                                                  avg =   16.0
                                                                  max =     16
                                                     Wald chi2(2)     = 339.62
Log likelihood = -686.72676                          Prob > chi2      = 0.0000

------------------------------------------------------------------------------
 Congruence1 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
      RL_HP  |    1.19865   .0651953    18.39   0.000      1.07087    1.326431
    TrialNum |  -.0179325   .0142133    -1.26   0.207    -.0457901    .0099251
       _cons |  -.5084515   .0956989    -5.31   0.000    -.6960179   -.3208852
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |   .0002895   .0210678      3.25e-66    2.58e+58
                  var(_cons) |   .0333368    .017686      .0117853    .0942988
-----------------------------+------------------------------------------------
               var(Residual) |   .6109038   .0391204      .5388458    .6925979
------------------------------------------------------------------------------
LR test vs. linear model: chi2(2) = 7.99                  Prob > chi2 = 0.0184

Note: LR test is conservative and provided only for reference.

. estimates store m1

. 
. mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log likelihood = -686.85785  
Iteration 1:  Log likelihood = -686.45422  
Iteration 2:  Log likelihood =  -686.4249  
Iteration 3:  Log likelihood = -686.42246  
Iteration 4:  Log likelihood = -686.42233  
Iteration 5:  Log likelihood = -686.42233  

Computing standard errors ...

Mixed-effects ML regression                          Number of obs    =    576
Group variable: PartID                               Number of groups =     36
                                                     Obs per group:
                                                                  min =     16
                                                                  avg =   16.0
                                                                  max =     16
                                                     Wald chi2(3)     = 340.25
Log likelihood = -686.42233                          Prob > chi2      = 0.0000

--------------------------------------------------------------------------------------
         Congruence1 | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
---------------------+----------------------------------------------------------------
           AgentType |
              RL_HP  |   1.320605   .1693017     7.80   0.000     .9887797     1.65243
            TrialNum |  -.0068457   .0200878    -0.34   0.733     -.046217    .0325256
                     |
AgentType#c.TrialNum |
              RL_HP  |  -.0221736   .0284084    -0.78   0.435    -.0778531    .0335058
                     |
               _cons |   -.569429   .1235039    -4.61   0.000    -.8114922   -.3273657
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |   .0004761   .0234673      5.30e-46    4.28e+38
                  var(_cons) |   .0334189    .017741      .0118064    .0945947
-----------------------------+------------------------------------------------
               var(Residual) |   .6101204   .0391628      .5379949    .6919154
------------------------------------------------------------------------------
LR test vs. linear model: chi2(2) = 8.02                  Prob > chi2 = 0.0181

Note: LR test is conservative and provided only for reference.

. estimates store m2

. 
. lrtest m1 m2 // chi2(1) = 0.61, p = .4352. 1-way model provides better fit.

Likelihood-ratio test
Assumption: m1 nested within m2

 LR chi2(1) =   0.61
Prob > chi2 = 0.4352

. 
. // To adjust for small samples, refit model with REML with Kenward-Roger estimates of error dof
. mixed Congruence1 i.AgentType c.TrialNum || PartID: i.AgentType, reml dfmethod(kroger)

Performing EM optimization ...

Performing gradient-based optimization: 
Iteration 0:  Log restricted-likelihood = -694.41877  
Iteration 1:  Log restricted-likelihood = -694.06462  
Iteration 2:  Log restricted-likelihood = -694.04565  
Iteration 3:  Log restricted-likelihood = -694.04525  
Iteration 4:  Log restricted-likelihood = -694.04525  

Computing standard errors ...

Computing degrees of freedom ...

Mixed-effects REML regression                        Number of obs    =    576
Group variable: PartID                               Number of groups =     36
                                                     Obs per group:
                                                                  min =     16
                                                                  avg =   16.0
                                                                  max =     16
DF method: Kenward–Roger                             DF:          min =  67.40
                                                                  avg = 308.33
                                                                  max = 520.41
                                                     F(2, 152.68)     = 165.02
Log restricted-likelihood = -694.04525               Prob > F         = 0.0000

------------------------------------------------------------------------------
 Congruence1 | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   AgentType |
      RL_HP  |    1.19865   .0660158    18.16   0.000     1.066896    1.330404
    TrialNum |  -.0179325   .0142182    -1.26   0.208    -.0458646    .0099997
       _cons |  -.5084515   .0961206    -5.29   0.000    -.6975231   -.3193799
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects parameters  |   Estimate   Std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
PartID: Independent          |
            var(2.AgentType) |     .00406   .0275235      6.89e-09    2393.113
                  var(_cons) |   .0360452   .0191286      .0127388    .1019919
-----------------------------+------------------------------------------------
               var(Residual) |   .6113242   .0395466      .5385267    .6939624
------------------------------------------------------------------------------
LR test vs. linear model: chi2(2) = 8.49                  Prob > chi2 = 0.0144

Note: LR test is conservative and provided only for reference.

. 
. estat df // to get error dof

Degrees of freedom
------------------------------
             |   Kenward–Roger
-------------+----------------
Congruence1  |
   AgentType |
         RL  |  (empty)
      RL_HP  |        67.39606
             |
    TrialNum |         520.406
       _cons |        337.1741
------------------------------

. 
. // RL_HP has significantly greater congruence than RL (contrast = 1.19865 z scoore), t(67.40) = 18.16, p < .001
. 
end of do-file
