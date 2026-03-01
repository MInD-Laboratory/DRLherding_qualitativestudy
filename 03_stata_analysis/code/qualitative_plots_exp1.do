*--------------------------------------------*
* Step 0: Import CSV
*--------------------------------------------*
clear all
set more off

* Set working directory if needed
* cd "C:/path/to/your/files"

* Import your CSV file
import delimited "ratings_combined_exp1.csv", clear

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
import delimited "ratings_combined_exp1.csv", clear
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

// Mixed model for Positive Attribution (component_num == 1)
mixed score i.agent_code i.block if component_num == 1 || part_id:, reml dfmethod(kroger)
margins agent_code, pwcompare(effects) mcompare(bonferroni)

// Mixed model for Strategy Effect (component_num == 2)
mixed score i.agent_code i.block if component_num == 2 || part_id:, reml dfmethod(kroger)
margins agent_code, pwcompare(effects) mcompare(bonferroni)

// Overall test of agent_code differences (only if needed)
contrast agent_code

// Standard chi-square test
tab q6 agent_code, chi2 row

// Adjusted residuals
ssc install tab_chi
tabchi q6 agent_code, r a


power repeated 4.4 3.8, varerror(2.56) corr(0.4) alpha(0.05) power(0.8)


