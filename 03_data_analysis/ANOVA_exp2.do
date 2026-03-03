// ANOVA - Experiment 2
// Auto-load data (expects working directory at 03_data_analysis)

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

// -----------------------------------------------------------------------------
// Describing the data
// -----------------------------------------------------------------------------
capture noisily tabstat TrialTime TA_Travel Congruence Human_Player_Travel, by(AgentType) statistic(mean sd min max n)
capture noisily tabulate AgentType, summarize(Congruence)
capture noisily tabulate AgentType, summarize(TA_Travel)
capture noisily tabulate AgentType, summarize(Human_Player_Travel)
capture noisily tabulate AgentType, summarize(TrialTime)

// -----------------------------------------------------------------------------
// ANOVA
// -----------------------------------------------------------------------------

anova TrialTime PartID AgentType TrialNum AgentType#TrialNum
margins AgentType, pwcompare(effects) mcompare(bonferroni)
pwmean TrialTime, over(AgentType) mcompare(bonferroni)

anova Congruence PartID AgentType TrialNum AgentType#TrialNum
margins AgentType, pwcompare(effects) mcompare(bonferroni)
tabstat Congruence, by(AgentType) statistic(mean sd n)

capture confirm variable TA_Travel
if _rc == 0 {
    anova TA_Travel PartID AgentType TrialNum AgentType#TrialNum
    pwmean TA_Travel, over(AgentType) mcompare(bonferroni)
}

capture confirm variable Human_Player_Travel
if _rc == 0 {
    anova Human_Player_Travel PartID AgentType TrialNum AgentType#TrialNum
    pwmean Human_Player_Travel, over(AgentType) mcompare(bonferroni)
}

// Robustness check: random intercept vs random slope (AgentType)
capture noisily mixed Congruence i.AgentType TrialNum || PartID:, mle
if _rc == 0 {
    estimates store m_ri
}
else {
    di as error "[WARN] Random-intercept mixed model failed with rc=" _rc
}

capture noisily mixed Congruence i.AgentType TrialNum || PartID: i.AgentType, covariance(unstructured) mle
if _rc == 0 {
    estimates store m_rs
}
else {
    di as error "[WARN] Random-slope mixed model failed with rc=" _rc
}

capture noisily estimates stats m_ri m_rs
di as txt "[INFO] m_ri vs m_rs are compared using AIC/BIC (lrtest not valid if models are non-nested)."
