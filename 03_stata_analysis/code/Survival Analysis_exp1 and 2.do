//Survival Analysis experiment 1

//Set up survivial analysis 
stset TrialTime, failure(Success=1)

graph set window fontface "Times New Roman" 
sts graph, by(AgentType) ci failure title("") ylabel(0(0.2)1, angle(0)) ytitle("Success Probability") xlabel(0(10)100, labsize(small)) legend(order(7 "Heuristic_AA" 9 "DRL-HP-AA" 8 "DRL-AA" 1 "95% CI" 5 "95% CI" 3 "95% CI") cols(7) position(1)) graphregion(color(white)) xtitle("Trial Time (s)")
// Determine which distribution is best for AFT

// note Congruence1 is Congruence z-scored
histogram Congruence, normal

// Run this first
frame create frame1 str32 model float(aic bic)
foreach model in exponential loglogistic weibull lognormal ggamma  {
    quietly mestreg AgentType##c.Congruence1 c.TrialNum || PartID:, distribution(`model') time
    quietly estat ic
    matrix S = r(S)
    frame post frame1 ("`model'") (S[1,5]) (S[1, 6])
}

// then run this
frame change frame1
format aic bic %3.2f
sort aic bic
list

// lognormal model is best fit (AIC = 7330.74; BIC = 7375.48)

frame change default
frame drop frame1


// Random-intercepts and Random-effect of Agent Type. Control for amount of decision-overlab (Congruence1 = z-scored Congruence), it's interaction, as well as TrialNum (serves as time)

mestreg i.AgentType c.Congruence1 i.AgentType#c.Congruence1 c.TrialNum || PartID: i.AgentType, distribution(lognormal) time tratio

contrast i.AgentType	// chi2(2) = 225.50, p < .0001
pwcompare i.AgentType, effects

margins, dydx(Congruence1) pwcompare(effects)	// Congruence slope is significant (52.01 slope); z = 5.64, p < .0001



margins i.AgentType, dydx(Congruence1)

margins AgentType, at(Congruence1=(-1(1)1)) vsquish 
marginsplot


// AgentType#Congruence1 interaction
contrast i.AgentType#c.Congruence1	//chi2(2) = 101.65, p < .0001

margins i.AgentType, dydx(Congruence1)
pwcompare i.AgentType#c.Congruence1, effects mcompare(bonferroni)

// RL slope is 1.62 more than DMP
// RL_HP slope is 0.54 more than DMP
// RL_HP slope is -1.08 less than RL

predict xbhat, xb  // Get linear predictor (log scale)
gen yhat = exp(xbhat)  // Convert back to original time scale
twoway (lfit TrialTime Congruence if AgentType == 1, lcolor(blue) lwidth(medium)) (lfit TrialTime Congruence if AgentType == 2, lcolor(orange) lwidth(medium)) (lfit TrialTime Congruence if AgentType == 3, lcolor(green) lwidth(medium)) (scatter TrialTime Congruence if AgentType == 1, mcolor(blue) msize(small)) (scatter TrialTime Congruence if AgentType == 2, mcolor(orange) msize(small)) (scatter TrialTime Congruence if AgentType == 3, mcolor(green) msize(small)), legend(order(1 "Heuristic-AA" 3 "DRL-HP-AA" 2 "DRL-AA") cols(9) position(1)) xtitle("Congruence") ytitle("Trial Time (s)") title("") ylabel(0(20)120)


// Experiment 2

//Set up survivial analysis 
stset TrialTime, failure(Success=1)

// Determine which distribution is best for AFT

// note Congruence1 is Congruence z-scored
histogram Congruence, normal

// Run this first
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
