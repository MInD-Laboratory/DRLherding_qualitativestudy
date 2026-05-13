// Qualitative Analysis Experiment 2
*--------------------------------------------*
* Step 0: Import CSV
*--------------------------------------------*
clear all
set more off

* Import your Exp2 CSV file
import delimited "data/ratings_combined_exp2.csv", clear

pca q1 q2 q3 q4 q5

* (Optional: Check loadings to confirm component meanings)
* pca, loading

*--------------------------------------------*
* Step 2: Predict the first two components
*--------------------------------------------*
predict pc1 pc2  // Extract first two components

*--------------------------------------------*
* Step 1: Create positive_attribution score
*--------------------------------------------*
egen positive_attribution = rowmean(q1 q2 q3 q5)

* Generate a component label and score variable
gen component = "Positive Attribution"
gen score = positive_attribution

* Keep only needed variables and save to disk
keep part_id agent_type component score block
save "temp_pos.dta", replace

*--------------------------------------------*
* Step 2: Re-import data for strategy effect
*--------------------------------------------*
import delimited "data/ratings_combined_exp2.csv", clear
gen component = "Strategy Effect"
gen score = q4
keep part_id agent_type component score block

* Append positive attribution rows
append using "temp_pos.dta"

*--------------------------------------------*
* Step 3: Keep only DRL agents (drop Heuristic-AA)
*--------------------------------------------*

* Recode agent_type
encode agent_type, gen(agent_code)
gen agent_code_ordered = .
replace agent_code_ordered = 1 if agent_code == 2  // DRL-HP-AA first
replace agent_code_ordered = 2 if agent_code == 1  // DRL-AA second

label define agentlbl 1 "DRL-HP-AA" 2 "DRL-AA"
label values agent_code_ordered agentlbl


*--------------------------------------------*
* Step 4: Create boxplot
*--------------------------------------------*
graph set window fontface "Times New Roman"
graph set print  fontface "Times New Roman"

graph box score, ///
    over(agent_code_ordered, label(angle(0) labsize(medlarge))) ///
    over(component, label(angle(0) labsize(medlarge))) ///
    asyvars ///
    box(1, color(green%50)) ///
    box(2, color(orange%50)) ///
    ytitle("Rating Score", size(medlarge)) ///
    ylabel(1(1)7, angle(0)) ///
	yscale(range(0.95 9)) ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    legend(order(1 "DRL-HP-AA" 2 "DRL-AA") size(medsmall)) ///
    name(myboxplot, replace)

graph display myboxplot, xsize(4) ysize(3)

*--------------------------------------------*
* Optional: Export graph
*--------------------------------------------*
graph export "ratings_boxplot_exp2.png", replace

encode component, gen(component_num)

*--------------------------------------------*
* Step 5: Descriptive statistics by agent and component
*--------------------------------------------*
bysort component agent_code_ordered: summarize score

*--------------------------------------------*
* Step 6: ICC check (justification for MLM)
*--------------------------------------------*
// Positive Attribution
mixed score if component_num == 1 || part_id:, reml
estat icc

// Strategy Effect
mixed score if component_num == 2 || part_id:, reml
estat icc

*--------------------------------------------*
* Step 7: LRT chi-square tests (ML, not REML)
*--------------------------------------------*
// Positive Attribution: null vs full model
mixed score i.block if component_num == 1 || part_id:, ml
estimates store null_pa

mixed score i.agent_code_ordered i.block if component_num == 1 || part_id:, ml
estimates store full_pa

lrtest null_pa full_pa  // chi2(1) for agent_code effect

// Strategy Effect: null vs full model
mixed score i.block if component_num == 2 || part_id:, ml
estimates store null_se

mixed score i.agent_code_ordered i.block if component_num == 2 || part_id:, ml
estimates store full_se

lrtest null_se full_se  // chi2(1) for agent_code effect

*--------------------------------------------*
* Step 8: Final REML + Kenward-Roger models for reporting
*--------------------------------------------*
// Positive Attribution
mixed score i.agent_code_ordered i.block if component_num == 1 || part_id:, reml dfmethod(kroger)
margins agent_code_ordered, pwcompare(effects)

// Strategy Effect
mixed score i.agent_code_ordered i.block if component_num == 2 || part_id:, reml dfmethod(kroger)
margins agent_code_ordered, pwcompare(effects)
