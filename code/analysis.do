* =============================================================================
* Chapter 40 — Binary Regression Models
* Example 1: Standard LPM & Probit Analysis
* SAGE Handbook of Quantitative Research Methods in Business and Management
*
* Companion paper:
*   https://www.sciencedirect.com/science/article/pii/S1048984324000158
*
* RUN ORDER:
*   1. min_effect_probit.R              (R — minimum detectable effect)
*   2. analysis.do                      <-- YOU ARE HERE
*   3. analysis_IV.do                   (IV / endogeneity analysis)
*
* REQUIRED STATA PACKAGES (uncomment and run once to install):
*   ssc install estout, replace         // esttab for regression tables
*   // interaction effect plots:
*   net install st0711, from("http://www.stata-journal.com/software/sj23-2")        
*   ssc install sensemakr, replace      // omitted variable sensitivity
*   // bootstrap sensitivity:
*   net install bootmakr, from("https://raw.githubusercontent.com/jespernwulff/bootmakr-stata/main/") replace       
*   ssc install spost13_ado, replace    // mchange for marginal effects
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

su employment_ga

* change from weeks to months
replace employment_ga = employment_ga/4
su employment_ga

 // minimum detectable effect size
* for coefficients and marginal effects in probit:
* probit: done in R using min_effect_probit.R
* minimum detectable effect probit beta at power=50% is -0.00651
* minimum detectable effect probit marginal effect at power=50% is -0.0026 (-0.00651*0.4)
* remember to compare to 90% CI!

* for marginal effects: can also aproximate by using linear reg
*power oneslope 0, n(9915) power(0.5) sdx(3)  direction(lower)

power oneslope 0, n(9915) power(0.5) sdx(3.8) sderror(.5)  direction(lower)
* MDE OLS slope = -0.0026
* remember to compare to 90% CI!

// Regression table
reg leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust
estimates store ols1

reg leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust
estimates store ols2

probit leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust
fitstat // get McKelvey & Zavoina Pseudo R2
estimates store pro1

probit leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust
fitstat // get McKelvey & Zavoina Pseudo R2
estimates store pro2


** findit esttab
set level 90
esttab ols1 ols2 pro1 pro2, ///
	mtitle("OLS" "OLS" "Probit" "Probit") ///
	nobaselevels ///
	keep(employment_gap eldisadv c.employment_gap#c.eldisadv) ///
	b(3) t(3)  ///
	label ///
	interaction(×) ///
	aic ///
	r2 pr2
	
// specification testing

* Load helper programs (probit_spec_test, reg_spec_test)
do "`project_root'/code/logit_spec_test.do"

* robust RESET for linear regression
reg_spec_test leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust

reg_spec_test leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust

* robust RESET for probit regression

probit_spec_test leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust

probit_spec_test leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust

* GOF test

probit leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust

estat gof
estat gof, group(10)

probit leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust

estat gof
estat gof, group(10)

// Marginal effects
quiet reg leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust
margins, dydx(employment_gap)

quiet probit leader employment_gap i.race age height mental_health i.immigrant num_children eldisadv i.sex, robust
margins, dydx(employment_gap)

mchange employment_gap, stats(change se zvalue pvalue ll ul) decimals(4)

// INTERACTIONS
quiet reg leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust
quiet margins, dydx(employment_gap) at(eldisadv=(-1.218 0 1.526))  post
estimates store ols2_dydx

quiet probit leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust
quiet margins, dydx(employment_gap) at(eldisadv=(-1.218 0 1.526))  post
estimates store prob2_dydx

esttab ols2_dydx prob2_dydx, ///
	mtitle("OLS" "Probit (dydx)") ///
	nobaselevels ///
	b(3) ///
	ci ///
	label ///
	level(90)

* Interaction Plots

* Run the probit model once
probit leader c.employment_gap##c.eldisadv i.race age height mental_health i.immigrant num_children i.sex, robust

* Plot 1: Margins plot with interaction
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

* Plot 2: Marginal effects
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

* APEs at 5th and 95th percentile of eldisadv
*set level 90
*margins, dydx(employment_gap) at(eldisadv = (-1.22 1.53)) level(90) post
* 2nd diff across ideal types
*mlincom 2 - 1, stat(all)

* Plot 3: Contour plot
quiet margins, at(employment_gap = (-7(1)7) eldisadv = (-1.218 (0.2) 1.526)) ///
	saving("output/predictions.dta", replace)
preserve
use "output/predictions", clear

twoway (contour _margin _at2 _at1, ccuts(.34(.02).56) crule(linear) scolor(white) ecolor(black))  ///
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
ginteff, dydxs(employment_gap eldisadv) obseff(int_effect) level(90)
ginteffplot, obseff(median pctile) zeroline(lpattern(dot) lwidth(thin)) ///
			xtitle("Change in Predicted Leadership Role") ///
			title("D. Average Interaction Effect") ///
			graphregion(fcolor(white) ilcolor(white) lcolor(white))


* Load the saved ginteff plot and combine all four plots
graph combine plot1 plot2 plot3 Graph, ///
	rows(2) cols(2) ///
	iscale(0.5) ///
	title("")

graph export "output/combined_analysis.emf", replace



// Sensitivity

* bootstrapped sensemakr on LPM
bootmakr leader employment_gap eldisadv i.race age height mental_health ///
		i.immigrant num_children i.sex,  ///
		gbenchmark(eldisadv  mental_health) kd(1) treat(employment_gap) ///
		reps(10000) dots(100) level(90)

capture program drop sensemakr_with_centering
program define sensemakr_with_centering, eclass
    capture drop eldisadv_cen
    quiet su eldisadv
    quiet gen eldisadv_cen = eldisadv - r(mean)

    sensemakr leader c.employment_gap##c.eldisadv_cen i.race age height ///
        mental_health i.immigrant num_children i.sex, treat(employment_gap) ///
        gbenchmark(eldisadv c.employment_gap#c.eldisadv_cen mental_health) kd(1)

    drop eldisadv_cen
end

bootmakr, program(sensemakr_with_centering) treat(employment_gap) ///
    reps(10000) dots(100) level(90)
