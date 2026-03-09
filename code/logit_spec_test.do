* =============================================================================
* Helper programs: probit_spec_test and reg_spec_test
* Pregibon-style link test (probit) and RESET-style test (OLS)
*
* Sourced automatically by analysis.do — no need to run
* this file on its own.
* =============================================================================

capture program drop probit_spec_test
program define probit_spec_test, eclass
    // Allow factor variables and options
    syntax varlist(fv min=2) [ , * ]

    // Parse dependent and independent variables
    gettoken y xvars : varlist

    // Create temporary variables to store predicted xb and terms
    tempvar xbhat xbhatsq xbhatcu

    // Step 1: Fit baseline model
    quietly probit `y' `xvars', `options'

    // Step 2: Predict linear predictor
    quietly predict `xbhat', xb

    // Step 3: Generate nonlinear terms
    quietly gen double `xbhatsq' = `xbhat'^2
    *quietly gen double `xbhatcu' = `xbhatsq'*`xbhat'

    // Step 4: Fit extended model
    quietly probit `y' `xvars' `xbhatsq', `options'

    // Step 5: Test significance
    test `xbhatsq' 
end

capture program drop reg_spec_test
program define reg_spec_test, eclass
    // Allow factor variables and options
    syntax varlist(fv min=2) [ , * ]

    // Parse dependent and independent variables
    gettoken y xvars : varlist

    // Create temporary variables to store predicted xb and terms
    tempvar xbhat xbhatsq xbhatcu

    // Step 1: Fit baseline model
    quietly reg `y' `xvars', `options'

    // Step 2: Predict linear predictor
    quietly predict `xbhat', xb

    // Step 3: Generate nonlinear terms
    quietly gen double `xbhatsq' = `xbhat'^2
    quietly gen double `xbhatcu' = `xbhatsq'*`xbhat'

    // Step 4: Fit extended model
    quietly reg `y' `xvars' `xbhatsq', `options'

    // Step 5: Test significance
    test `xbhatsq' 
end