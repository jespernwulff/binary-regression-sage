* =============================================================================
* Binary Regression Models: An Average Partial Effects Approach
* Example 2: Instrumental Variables / Endogeneity Analysis
* The SAGE Handbook of Quantitative Research Methods in Business & Management
*
* Companion paper:
*   https://www.sciencedirect.com/science/article/pii/S1048984324000158
*
* RUN ORDER:
*   1. min_effect_probit.R              (R — minimum detectable effect)
*   2. analysis.do                      (standard LPM & probit)
*   3. analysis_IV.do                   <-- YOU ARE HERE
*
* REQUIRED STATA PACKAGES (uncomment and run once to install):
*   ssc install estout, replace         // esttab for regression tables
*   net install st0711, from("http://www.stata-journal.com/software/sj23-2")        // interaction effect plots
*   ssc install ivreg2, replace         // 2SLS estimation
*   ssc install testex, replace         // exclusion restriction tests
*   ssc install twostepweakiv, replace  // weak IV robust inference
*   ssc install plausexog, replace      // plausibly exogenous bounds
*   ssc install weakiv, replace         // weak IV diagnostics
*   ssc install spost13_ado, replace    // mlincom for linear combinations
*
* SETUP: Set project_root below to the folder containing this repository.
*        If you open Stata in the project root, leave it as ".".
* =============================================================================

clear all
set more off

* --- USER: Set this to your project root directory ---
local project_root "."

cd "`project_root'"

* Load data
use "data/master_rev2", clear

replace employment_ga = employment_ga/4
su employment_ga


* Estimating IV models
ivreg2 leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (employment_gap = dummy highest_degree), robust level(90) endog(employment_gap) ffirst saverf
estimates store twostage

**CF approach
capture drop ____CF_EnDoG1_1
cfprobit leader eldisadv i.race age height mental_health i.immigrant num_children  i.sex ///
	(employment_gap = dummy highest_degree), robust

margins, dydx(employment_gap)  post level(90)
estimates store cfprob

ivreg2 leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (c.employment_gap c.employment_gap#c.eldisadv = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), robust level(90) endog(employment_gap c.employment_gap#c.eldisadv) ffirst saverf
margins, dydx(employment_gap) at(eldisadv = (-1.218 0 1.526))  post
estimates store twostage2

capture drop ____CF_EnDoG1_1
capture drop ____CF_EnDoG2_1
cfprobit leader eldisadv i.race age height mental_health i.immigrant num_children  i.sex ///
	(employment_gap = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv ) ///
	(c.employment_gap#c.eldisadv =  dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), cfinteract robust
margins, dydx(employment_gap) at(eldisadv = (-1.218 0 1.526))    post
estimates store cfprob2


set level 90
esttab twostage cfprob twostage2  cfprob2, ///
	mtitle("LPM (2SLS)" "CF probit (two-step)" "LPM (2SLS)" "CF probit (two-step)") ///
	nobaselevels 	///
	keep(employment_gap 1._at 2._at 3._at ) ///
	b(3) se(3)  ///
	label

set level 90
esttab twostage cfprob twostage2 cfprob2, ///
	mtitle("LPM (2SLS)" "CF probit (two-step)" "LPM (2SLS)"  "CF probit (two-step)") ///
	nobaselevels 	///
	keep(employment_gap 1._at 2._at 3._at ) ///
	b(3) ci(3)  ///
	label

* 2SLS diagnostics
ivreg2 leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (employment_gap = dummy highest_degree), robust level(90) endog(employment_gap) ffirst

ivreg2 leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (c.employment_gap c.employment_gap#c.eldisadv = dummy dummy#c.eldisadv highest_degree highest_degree#c.eldisadv), robust level(90) endog(employment_gap c.employment_gap#c.eldisadv) ffirst


** CF diagnostics

* endogeneity
capture drop ____CF_EnDoG1_1
cfprobit leader eldisadv i.race age height mental_health i.immigrant num_children  i.sex ///
	(employment_gap = dummy highest_degree), robust
estat endogenous

capture drop ____CF_EnDoG1_1
capture drop ____CF_EnDoG2_1
cfprobit leader eldisadv i.race age height mental_health i.immigrant num_children  i.sex ///
	(employment_gap = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv ) ///
	(c.employment_gap#c.eldisadv =  dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), cfinteract robust
estat endogenous

* exclusion restriction test
* findit testex
testex leader employment_gap dummy , numboot(2000)
testex leader employment_gap highest_degree , numboot(2000)

capture drop employment_gap_int
gen employment_gap_int = employment_gap*eldisadv

testex leader employment_gap_int dummy , numboot(2000)
testex leader employment_gap_int highest_degree , numboot(2000)

* LPM by 2SLS interaction figure

ivreg2 leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (c.employment_gap c.employment_gap#c.eldisadv = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), robust level(90) endog(employment_gap c.employment_gap#c.eldisadv) ffirst saverf

margins, at(employment_gap = (-7(1)7) eldisadv = (-1.218 1.526))

marginsplot,   ///
    recastci(rarea) ///
	recast(line) ///
	plot1opts(lcolor(black)) ///
	plot2opts(lpattern(dot) lcolor(black)) ///
	ci1opts(fcolor(black%30) lwidth(none)) ///
	ci2opts(fcolor(black%30) lwidth(none)) ///
	plotopts(msymbol(none)) ///
	ytitle("Predicted Leadership Role") ///
	xtitle("Employment gap (Months)") ///
	title("A. Predicted Probabilities") ///
	legend(position(1) ring(0) cols(1) ///
		label(3 "Early Life Disadvantage = -1.218 (5th percentile)") ///
		label(4 "Early Life Disadvantage = 1.526 (95th percentile)") ///
		order(3 4) ///
		region(fcolor(white) lcolor(black) lwidth(thin)) ///
		symxsize(*.5)) ///
	name(plot1, replace) ///
	level(90)

margins, dydx(employment_gap) at(eldisadv = (-1.218 (0.2) 1.526))
marginsplot, ///
	recastci(rarea) ///
	ciopts(fcolor(black%30) lwidth(none)) ///
	plotopts(msymbol(none) lcolor(black)) ///
	ytitle("Marginal Effect of Employment Gap") ///
	xtitle("Early Life Disadvantage") ///
	title("B. Marginal Effects") ///
	yline(0, lpattern(dot) lwidth(thin)) ///
	yline(-0.0026, lwidth(thin)) ///
	yline(0.0026, lwidth(thin)) ///
	name(plot2, replace) ///
	level(90)

* Combine 2SLS interaction plots
graph combine plot1 plot2, ///
	rows(2) cols(2) ///
	iscale(0.5) ///
	title("")

graph export "output/endo_2sls.emf", replace



* Interaction effect analysis of control function probit

capture drop ____CF_EnDoG1_1
capture drop ____CF_EnDoG2_1
cfprobit leader eldisadv i.race age height mental_health i.immigrant num_children  i.sex ///
	(employment_gap = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv ) ///
	(c.employment_gap#c.eldisadv =  dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), cfinteract robust

margins, at(employment_gap = (-7(1)7) eldisadv = (-1.218 1.526))  predict(pr)

marginsplot,   ///
    recastci(rarea) ///
	recast(line) ///
	plot1opts(lcolor(black)) ///
	plot2opts(lpattern(dot) lcolor(black)) ///
	ci1opts(fcolor(black%30) lwidth(none)) ///
	ci2opts(fcolor(black%30) lwidth(none)) ///
	plotopts(msymbol(none)) ///
	ytitle("Predicted Leadership Role") ///
	xtitle("Employment gap (Months)") ///
	title("A. Predicted Probabilities") ///
	legend(position(1) ring(0) cols(1) ///
		label(3 "Early Life Disadvantage = -1.218 (5th percentile)") ///
		label(4 "Early Life Disadvantage = 1.526 (95th percentile)") ///
		order(3 4) ///
		region(fcolor(white) lcolor(black) lwidth(thin)) ///
		symxsize(*.5)) ///
	name(plot1, replace) ///
	level(90)

margins, dydx(employment_gap) at(eldisadv = (-1.218 (0.2) 1.526))  predict(pr)
marginsplot, ///
	recastci(rarea) ///
	ciopts(fcolor(black%30) lwidth(none)) ///
	plotopts(msymbol(none) lcolor(black)) ///
	ytitle("Marginal Effect of Employment Gap") ///
	xtitle("Early Life Disadvantage") ///
	title("B. Marginal Effects") ///
	yline(0, lpattern(dot) lwidth(thin)) ///
	yline(-0.0026, lwidth(thin)) ///
	yline(0.0026, lwidth(thin)) ///
	name(plot2, replace) ///
	level(90)


* APEs at 5th and 95th percentile of eldisadv
set level 90
margins, dydx(employment_gap) at(eldisadv = (-1.22 1.53)) level(90)  predict(pr)
* 2nd diff across ideal types
mlincom 2 - 1, stat(all)

* Plot 3: Contour plot
quiet margins, at(employment_gap = (-7(1)7) eldisadv = (-1.218 (0.2) 1.526)) ///
	 predict(pr) ///
	saving("output/predictions.dta", replace)
preserve
use "output/predictions", clear

su _margin

twoway (contour _margin _at2 _at1, ccuts(0(.1)1) crule(linear) scolor(white) ecolor(black))  ///
        , xlabel(-7(1)7) ///
        ylabel(-1.2(0.2)1.2, angle(horizontal)) ///
        xtitle("Employment gap (Months)", margin(medium)) ///
        ytitle("Early Life Disadvantage", margin(medium)) ///
        ztitle("Predicted Leadership Role") ///
        title("C. Contour Plot") ///
		name(plot3, replace)
restore

* Plot 4: GINTEFF
*search ginteff
capture drop ____CF_EnDoG1_1 ____CF_EnDoG2_1
ginteff, firstdiff(employment_gap eldisadv) level(90) predict(pr)

ginteffplot, obseff(median pctile) zeroline(lpattern(dot) lwidth(thin)) ///
			xtitle("Change in Predicted Leadership Role") ///
			title("D. Average Interaction Effect") ///
			graphregion(fcolor(white) ilcolor(white) lcolor(white))


* Combine all four CF probit plots
graph combine plot1 plot2 plot3 Graph, ///
	rows(2) cols(2) ///
	iscale(0.5) ///
	title("")

graph export "output/combined_analysis_endo.emf", replace


*Sensitivity
** weak IV

twostepweakiv 2sls leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (employment_gap = dummy highest_degree), robust usegrid

twostepweakiv 2sls leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (c.employment_gap c.employment_gap#c.eldisadv = dummy dummy##c.eldisadv highest_degree highest_degree##c.eldisadv), robust usegrid project(c.employment_gap#c.eldisadv) gridmin(-.12) gridmax(0.1)

twostepweakiv 2sls leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (c.employment_gap c.employment_gap#c.eldisadv = dummy eldisadv dummy#c.eldisadv highest_degree highest_degree#c.eldisadv), robust usegrid project(c.employment_gap )  gridmin(-.35) gridmax(0)

*Exclusion restriction
plausexog uci leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (employment_gap = dummy highest_degree), robust robust gmin(-0.0025 -0.0025) gmax(0.0025 0.0025) grid(10) level(.95)

plausexog uci leader eldisadv  i.race age height mental_health i.immigrant num_children i.sex (employment_gap = dummy highest_degree), robust robust gmin(-0.0025 -0.0025) gmax(0.0025 0.0025) grid(10) level(.90)


** Check worst case (takes a while to run)
* set maxvar 20000
plausexog uci leader eldisadv  i.race age height mental_health           ///
          i.immigrant num_children i.sex                                 ///
          (c.employment_gap c.employment_gap#c.eldisadv =                ///
           dummy                                                         ///
           0b.dummy#c.eldisadv                                           ///
           highest_degree                                                ///
           0b.highest_degree#c.eldisadv                                  ///
           1.highest_degree#c.eldisadv                                   ///
           2.highest_degree#c.eldisadv                                   ///
           3.highest_degree#c.eldisadv),                                 ///
          robust                                                         ///
          gmin(-0.0025 -0.0025 -0.0025 -0.0025 -0.0025 -0.0025 -0.0025)                   ///
          gmax( 0.0025  0.0025 0.0025 0.0025       0.0025       0.0025      0.0025)          ///
         grid(4)