//// Mixed effects model for congrunce_ Experiment2
clear all
set more off

local data_file "data/Long format Perf Experiment2.dta"
capture confirm file "`data_file'"
if _rc {
    di as error "[ERROR] Could not find `data_file'. Set working directory to 03_data_analysis and re-run."
    exit 601
}

use "`data_file'", clear
// Exclude practice trial from all analyses
keep if TrialNum != 1

histogram Congruence

// We will fit a linear mixed-effects model, with observations nested under participant. In addition to a random-intercept for each participant, we include a random slope for AgentType.

// Fixed effects will include AgentType, TrialNum (to control for learning) and an AgentType x TrialNum interaction

// We will treat TrialNum as a continuous covariate to understand average learning slope

// We use Congruence1, which is Congruence z-scored.

// First test if 2-way model significantly improves model fit
mixed Congruence1 i.AgentType c.TrialNum || PartID: i.AgentType
estimates store m1

mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType
estimates store m2

lrtest m1 m2 // chi2(1) = 0.61, p = .4352. 1-way model provides better fit.

// To adjust for small samples, refit model with REML with Kenward-Roger estimates of error dof
mixed Congruence1 i.AgentType c.TrialNum || PartID: i.AgentType, reml dfmethod(kroger)

estat df // to get error dof

// RL_HP has significantly greater congruence than RL (contrast = 1.19865 z scoore), t(67.40) = 18.16, p < .001