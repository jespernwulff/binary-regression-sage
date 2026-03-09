---
layout: default
title: "Replication Code"
---

# Chapter 40: Limited Dependent Variables

**Author:** Jesper N. Wulff
**Book:** *SAGE Handbook of Quantitative Methods for the Social Sciences* (2nd Edition)

---

## Overview

This repository contains the replication code for Chapter 40 on limited dependent variables (LDVs). The chapter covers binary regression models including linear probability models (LPM), probit, instrumental variables (IV) estimation, and control-function approaches, with a focus on specification testing, marginal effects, interaction effects, and sensitivity analysis.

---

## Code Files

| File | Language | Description |
|------|----------|-------------|
| [`min_effect_probit.R`]({{ site.github.repository_url }}/blob/main/code/min_effect_probit.R) | R | Minimum detectable effect size (power analysis for probit) |
| [`analysis.do`]({{ site.github.repository_url }}/blob/main/code/analysis.do) | Stata | **Example 1:** LPM and probit with specification tests, marginal effects, interaction effects, and sensitivity analysis |
| [`analysis_IV.do`]({{ site.github.repository_url }}/blob/main/code/analysis_IV.do) | Stata | **Example 2:** IV/2SLS, IV probit, and control-function probit with diagnostics |
| [`logit_spec_test.do`]({{ site.github.repository_url }}/blob/main/code/logit_spec_test.do) | Stata | Helper programs for specification testing (sourced automatically by Example 1) |

---

## Prerequisites

### Stata (version 17 or later recommended)

Install the following community-contributed packages by running these commands in Stata:

```stata
* Packages for Example 1 (analysis.do)
ssc install estout, replace
ssc install ginteff, replace
ssc install sensemakr, replace
ssc install bootmakr, replace
ssc install spost13_ado, replace

* Additional packages for Example 2 (analysis_IV.do)
ssc install ivreg2, replace
ssc install ranktest, replace
ssc install cfprobit, replace
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

The dataset `master_rev2.dta` is included in the `data/` folder of this repository.

---

## Citation

[Citation to be added upon publication.]
