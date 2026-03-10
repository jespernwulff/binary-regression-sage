---
layout: default
title: "Replication Code"
---

# Binary Regression Models: An Average Partial Effects Approach

**Author:** Jesper N. Wulff
**Book:** *The SAGE Handbook of Quantitative Research Methods in Business & Management*

---

## Overview

This repository contains the replication code for the chapter on binary regression models. The chapter covers linear probability models (LPM), probit, instrumental variables (IV) estimation, and control-function approaches, with a focus on specification testing, marginal effects, interaction effects, and sensitivity analysis.

---

## Code Files

| File | Language | Description |
|------|----------|-------------|
| [`min_effect_probit.R`]({{ site.github.repository_url }}/blob/main/code/min_effect_probit.R) | R | Minimum detectable effect size (power analysis for probit) |
| [`analysis.do`]({{ site.github.repository_url }}/blob/main/code/analysis.do) | Stata | **Example 1:** LPM and probit with specification tests, marginal effects, interaction effects, and sensitivity analysis |
| [`analysis_IV.do`]({{ site.github.repository_url }}/blob/main/code/analysis_IV.do) | Stata | **Example 2:** 2SLS and control-function probit with diagnostics |
| [`logit_spec_test.do`]({{ site.github.repository_url }}/blob/main/code/logit_spec_test.do) | Stata | Helper programs for specification testing (sourced automatically by Example 1) |

---

## Prerequisites

### Stata 19

`analysis_IV.do` uses the `cfprobit` command, which is built into Stata 19. Install the following community-contributed packages by running these commands in Stata:

```stata
* Packages for Example 1 (analysis.do)
ssc install estout, replace
net install st0711, from("http://www.stata-journal.com/software/sj23-2")
ssc install sensemakr, replace
net install bootmakr, from("https://raw.githubusercontent.com/jespernwulff/bootmakr-stata/main/") replace
ssc install spost13_ado, replace

* Additional packages for Example 2 (analysis_IV.do)
ssc install ivreg2, replace
ssc install testex, replace
ssc install twostepweakiv, replace
ssc install plausexog, replace
ssc install weakiv, replace
```

### R (version 4.0 or later)

```r
install.packages("pwrss")
```

---

## How to Run

1. **Clone or download** this repository.
2. **Install** the required packages listed above.
3. **Set `project_root`**: Open each `.do` file and set the `project_root` local macro at the top to the path where you saved this repository. If you open Stata with the project folder as your working directory, the default value of `"."` will work without changes.
4. **Run the files in order:**
   - `code/min_effect_probit.R` (in R)
   - `code/analysis.do` (in Stata)
   - `code/analysis_IV.do` (in Stata)

Generated figures will be saved to the `output/` folder.

---

## Data

The dataset `master_rev2.dta` is included in the `data/` folder. The data are from:

Epitropaki O and Avramidis P (2024) Becoming a leader with clipped wings: The role of early-career unemployment scarring on future leadership role occupancy. *The Leadership Quarterly* 35(4): 101786. [https://doi.org/10.1016/j.leaqua.2024.101786](https://doi.org/10.1016/j.leaqua.2024.101786)

---

## Citation

Wulff, J. N. (2026). Binary regression models: An average partial effects approach. In J. R. Busenbark & M. Withers (Eds.), *The SAGE Handbook of Quantitative Research Methods in Business & Management*. SAGE Publications Ltd.
