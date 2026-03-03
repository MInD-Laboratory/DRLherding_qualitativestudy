// Survival Analysis Experiment 2
clear all
set more off

local data_file "data/Long format Perf Experiment2.dta"
capture confirm file "`data_file'"
if _rc {
    di as error "[ERROR] Could not find `data_file'. Set working directory to 03_data_analysis and re-run."
    exit 601
}

use "`data_file'", clear

//Set up survivial analysis 
stset TrialTime, failure(Success=1)

// Determine which distribution is best for AFT

// note Congruence1 is Congruence z-scored
histogram Congruence, normal

// Run this first. Could not fit model with AgentType as random slope so removed.
frame create frame2 str32 model float(aic bic)
foreach model in exponential loglogistic weibull lognormal ggamma  {
    quietly mestreg AgentType##c.Congruence1 c.TrialNum || PartID:, distribution(`model') time
    quietly estat ic
    matrix S = r(S)
    frame post frame2 ("`model'") (S[1,5]) (S[1, 6])
}

// Then run this
frame change frame2
format aic bic %3.2f
sort aic bic
list

// lognormal model is best fit. (AIC = 5291.53, BIC = 5322.85)

frame change default
frame drop frame2

// Fit same model as in Experiment 1.
mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

pwcompare i.AgentType, effects	// z = -5.17, p < .0001
margins, dydx(Congruence1) pwcompare(effects)	// Congruence slope is significant (14.75 slope); z = 5.08, p < .0001


// AgentType#Congruence1 interaction
contrast i.AgentType#c.Congruence1	//chi2(1) = 4.11, p = .0426

margins i.AgentType, dydx(Congruence1)
pwcompare i.AgentType#c.Congruence1, effects mcompare(bonferroni)

// RL_HP slope is -0.156 less than RL (z = -2.03, p = 0.043)

// Check for multicollinearity and non-linearity
gen ln_time = ln(_t)
reg ln_time i.AgentType c.Congruence1##i.AgentType c.TrialNum
estat vif

// Original Model
mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio
estimates store m1

// Check if Quadratic Term improves model fit.
mestreg i.AgentType c.Congruence1 c.Congruence1#c.Congruence1 ///
    i.AgentType#c.Congruence1 i.AgentType#c.Congruence1#c.Congruence1 c.TrialNum ///
    || PartID: i.AgentType, distribution(lognormal) time
estimates store m2

lrtest m1 m2	// lr-test chi2(2) = 55.29, p < .0001

// Test for interaction between quadratic term and AA type
contrast i.AgentType#c.Congruence1#c.Congruence1 // chi2(1) = 0.59, p = .4406
