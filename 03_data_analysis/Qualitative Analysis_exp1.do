// Qualitative analysis Experiment 1
*--------------------------------------------*
* Step 0: Import CSV
*--------------------------------------------*
clear all
set more off

* Set working directory if needed
* cd "C:/path/to/your/files"

* Import your CSV file
import delimited "data/ratings_combined_exp1.csv", clear

*--------------------------------------------*
* Step 1: PCA to confirm component structure
*--------------------------------------------*
pca q1 q2 q3 q4 q5

*--------------------------------------------*
* Step 2: Create positive_attribution score
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
import delimited "data/ratings_combined_exp1.csv", clear
gen component = "Strategy Effect"
gen score = q4
keep part_id agent_type component score block

* Append positive attribution rows
append using "temp_pos.dta"

*--------------------------------------------*
* Step 3: Recode agent_type for cleaner labels
*--------------------------------------------*
encode agent_type, gen(agent_code)
label define agent_lbl 1 "Heuristic-AA" 2 "DRL-HP-AA" 3 "DRL-AA"
label values agent_code agent_lbl


*--------------------------------------------*
* Step 4: Create boxplot
*--------------------------------------------*
graph set window fontface "Times New Roman"
graph set print  fontface "Times New Roman"
graph box score, ///
    over(agent_code, label(angle(0) labsize(medlarge))) ///
    over(component, label(angle(0) labsize(medlarge))) ///
    asyvars ///
    box(1, color(blue%50)) ///
	box(2, color(green%50)) ///
	box(3, color(orange%50)) ///
    ytitle("Rating Score", size(medlarge)) ///
	ylabel(1(1)7, angle(0)) ///
	yscale(range(0.95 9)) ///
    graphregion(color(white)) ///
    plotregion(margin(zero)) ///
    legend(order(1 "Heuristic-AA" 2 "DRL-HP-AA" 3 "DRL-AA") size(medsmall)) ///
	name(myboxplot, replace)  ///

graph display myboxplot, xsize(4) ysize(3)

*--------------------------------------------*
* Optional: Export graph
*--------------------------------------------*
graph export "ratings_boxplot_exp1.png", replace

encode component, gen(component_num)

*--------------------------------------------*
* Descriptive statistics by agent and component
*--------------------------------------------*
bysort component agent_code: summarize score

*--------------------------------------------*
* ICC check (justification for MLM)
*--------------------------------------------*
mixed score if component_num == 1 || part_id:, reml
estat icc

mixed score if component_num == 2 || part_id:, reml
estat icc

*--------------------------------------------*
* LRT chi-square for AA type effect (ML, not REML)
*--------------------------------------------*
// Positive Attribution
mixed score i.block if component_num == 1 || part_id:, ml
estimates store null_pa

mixed score i.agent_code i.block if component_num == 1 || part_id:, ml
estimates store full_pa

lrtest null_pa full_pa  // chi2(2) for AA type effect on positive attribution

// Strategy Effect
mixed score i.block if component_num == 2 || part_id:, ml
estimates store null_se

mixed score i.agent_code i.block if component_num == 2 || part_id:, ml
estimates store full_se

lrtest null_se full_se  // chi2(2) for AA type effect on strategy effect

*--------------------------------------------*
* Final REML + Kenward-Roger models for reporting
*--------------------------------------------*
// Positive Attribution
mixed score i.agent_code i.block if component_num == 1 || part_id:, reml dfmethod(kroger)
contrast agent_code   // chi2(2) for AA type
margins agent_code, pwcompare(effects) mcompare(bonferroni)

// Strategy Effect
mixed score i.agent_code i.block if component_num == 2 || part_id:, reml dfmethod(kroger)
contrast agent_code   // chi2(2) for AA type
margins agent_code, pwcompare(effects) mcompare(bonferroni)

// Standard chi-square test (reload raw file because q6 was dropped earlier)
import delimited "data/ratings_combined_exp1.csv", clear
encode agent_type, gen(agent_code)

local q6var "q6"
capture confirm variable q6
if _rc != 0 {
    capture confirm variable Q6
    if _rc == 0 {
        local q6var "Q6"
    }
    else {
        di as error "[ERROR] q6 (or Q6) not found in ratings_combined_exp1.csv"
        exit 111
    }
}

tab `q6var' agent_code, chi2 row

// Adjusted residuals
ssc install tab_chi
tabchi `q6var' agent_code, r a


power repeated 4.4 3.8, varerror(2.56) corr(0.4) alpha(0.05) power(0.8)


