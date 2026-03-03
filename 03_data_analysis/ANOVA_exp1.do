// ANOVA - Experiment 1
// Auto-load data (expects working directory at 03_data_analysis)

clear all
set more off

local data_file "data/Long format Perf Experiment1.dta"
capture confirm file "`data_file'"
if _rc {
    di as error "[ERROR] Could not find `data_file'. Set working directory to 03_data_analysis and re-run."
    exit 601
}

use "`data_file'", clear

// -----------------------------------------------------------------------------
// Describing the data
// -----------------------------------------------------------------------------
capture noisily tabstat TrialTime TA_Travel Congruence Human_Player_Travel, by(AgentType) statistic(mean sd min max n)
capture noisily tabulate AgentType, summarize(Congruence)
capture noisily tabulate AgentType, summarize(TA_Travel)
capture noisily tabulate AgentType, summarize(Human_Player_Travel)
capture noisily tabulate AgentType, summarize(TrialTime)

// -----------------------------------------------------------------------------
// Baseline + centered congruence variable
// -----------------------------------------------------------------------------
capture confirm variable Congruence1
if _rc != 0 {
    egen Congruence1 = std(Congruence)
}

capture drop baseline
bysort PartID AgentType (TrialNum): gen baseline = TrialTime if TrialNum == 1
by PartID AgentType: replace baseline = baseline[1]

// -----------------------------------------------------------------------------
// ANOVA
// -----------------------------------------------------------------------------

anova TrialTime PartID AgentType TrialNum AgentType#TrialNum c.baseline
pwmean TrialTime, over(AgentType) mcompare(bonferroni)

anova Congruence PartID AgentType TrialNum AgentType#TrialNum c.baseline
margins AgentType, pwcompare(effects) mcompare(bonferroni)
tabstat Congruence, by(AgentType) statistic(mean sd n)

capture confirm variable TA_Travel
if _rc == 0 {
    anova TA_Travel PartID AgentType TrialNum AgentType#TrialNum c.baseline
    pwmean TA_Travel, over(AgentType) mcompare(bonferroni)
}

capture confirm variable Human_Player_Travel
if _rc == 0 {
    anova Human_Player_Travel PartID AgentType TrialNum AgentType#TrialNum c.baseline
    pwmean Human_Player_Travel, over(AgentType) mcompare(bonferroni)
}

// Optional follow-up model
capture noisily mixed Congruence i.AgentType TrialNum c.baseline || PartID:, reml
