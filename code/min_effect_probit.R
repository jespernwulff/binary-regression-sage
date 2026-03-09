# =============================================================================
# Binary Regression Models: An Average Partial Effects Approach
# Minimum Detectable Effect Size for Probit (Power Analysis)
#
# REQUIRED R PACKAGE (install once):
#   install.packages("pwrss")
#
# This script finds the minimum detectable logit beta1 at a given power,
# then converts to the probit coefficient and average marginal effect.
#
# RUN ORDER: Run this before the Stata .do files.
# =============================================================================

library(pwrss)

# Simple example
pwrss.z.logreg(p0 = 0.5, r2.other.x = 0.4,
                alpha = 0.05, beta1 = -0.05087, n=9915,
               distribution = list(dist = "normal", mean = 0, sd = 3),
               )

# function that finds minimum effect using binary search
find_beta1_for_power <- function(target_power = 0.5, 
                                 p0 = 0.5, 
                                 r2.other.x = 0.4,
                                 alpha = 0.05, 
                                 n = 9915,
                                 dist = "normal",
                                 tolerance = 1e-4,
                                 max_iterations = 100,
                                 beta_min = -1,
                                 beta_max = 1) {
  
  library(pwrss)
  
  iterations <- 0
  lower <- beta_min
  upper <- beta_max
  
  # Binary search algorithm
  while ((upper - lower) > tolerance && iterations < max_iterations) {
    iterations <- iterations + 1
    mid <- (lower + upper) / 2
    
    # Calculate power at the midpoint
    current_power <- pwrss.z.logreg(p0 = p0, 
                                    r2.other.x = r2.other.x,
                                    alpha = alpha, 
                                    beta1 = mid, 
                                    n = n,
                                    dist = dist,
                                    verbose = FALSE)$power
    
    # Adjust search boundaries based on comparison with target power
    if (current_power < target_power) {
      # If power is too small, we need a larger effect size (more negative for negative beta1)
      if (mid < 0) {
        upper <- mid  # For negative beta1, make it more negative
      } else {
        lower <- mid  # For positive beta1, make it larger
      }
    } else {
      # If power is too large, we need a smaller effect size
      if (mid < 0) {
        lower <- mid  # For negative beta1, make it less negative
      } else {
        upper <- mid  # For positive beta1, make it smaller
      }
    }
  }
  
  # Final check with the midpoint
  final_beta <- (lower + upper) / 2
  final_power <- pwrss.z.logreg(p0 = p0, 
                                r2.other.x = r2.other.x,
                                alpha = alpha, 
                                beta1 = final_beta, 
                                n = n,
                                dist = dist,
                                verbose = FALSE)
  
  return(list(beta1 = final_beta, 
              power = final_power$power, 
              iterations = iterations))
}

result <- find_beta1_for_power(target_power = 0.5,
                               p0 = 0.5,
                               r2.other.x = 0.01,
                               alpha = 0.05,
                               n = 9915,
                               dist = list(dist = "normal", mean = 0, sd = 3))

# Print results
print(paste("Logit beta1 value for power = 0.5:", round(result$beta1, 5)))
print(paste("Probit beta1 value for power = 0.5:", round(result$beta1/1.6, 5))) # b_logit = 1.6*b_probit
print(paste("Probit marginal effect value for power = 0.5:", round(result$beta1/1.6*0.4, 5))) #AME <= 0.4*beta_probit
print(paste("Actual power achieved:", round(result$power, 5)))
print(paste("Iterations required:", result$iterations))


