// Mixed effects model for congrunce_ Experiment1

clear all
set more off

local data_file "data/Long format Perf Experiment1.dta"
capture confirm file "`data_file'"
if _rc {
    di as error "[ERROR] Could not find `data_file'. Set working directory to 03_data_analysis and re-run."
    exit 601
}

use "`data_file'", clear
// Exclude practice trial from all analyses
keep if TrialNum != 1


// We will fit a linear mixed-effects model, with observations nested under participant. In addition to a random-intercept for each participant, we include a random slope for AgentType.

// Fixed effects will include AgentType, TrialNum (to control for learning) and an AgentType x TrialNum interaction

// We will treat TrialNum as a continuous covariate to understand average learning slope

// We use Congruence1, which is Congruence z-scored.

// First test if 2-way model significantly improves model fit
mixed Congruence1 i.AgentType c.TrialNum || PartID: i.AgentType
estimates store m1

mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType
estimates store m2

lrtest m1 m2 // chi2(2) = 6.91, p = .0315. 2-way model provides better fit.

// To adjust for small samples, refit model with REML with Kenward-Roger estimates of error dof
mixed Congruence1 i.AgentType c.TrialNum i.AgentType#c.TrialNum || PartID: i.AgentType, reml dfmethod(kroger)

// 1-way effects
contrast i.AgentType, small	// F(2, 893.19) = 203.44, p < .0001
pwcompare i.AgentType, small effects mcompare(bonf) // all p < .001

margins i.AgentType // Presents marginal predicted means. This is represented as z-scores

// 2-way effect
contrast i.AgentType#c.TrialNum, small // F(2, 902.46) = 3.46, p = .0319

pwcompare (c.TrialNum#AgentType), mcompare(bonf) small // to get error dof
pwcompare (c.TrialNum#AgentType), effects mcompare(bonf) small
// RL has more negative slope compared to DMP condition (contrast = -0.0720501), t(902.5) = -2.59, p = .029. Other comparisons are p >= .278