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
               alpha = 0.05, beta1 = -0.05087, n = 9915,
               distribution = list(dist = "normal", mean = 0, sd = 3))

# Function that finds minimum |beta1| for a given power using binary search
find_beta1_for_power <- function(target_power = 0.5, 
                                 p0 = 0.5, 
                                 r2.other.x = 0.4,
                                 alpha = 0.05, 
                                 n = 9915,
                                 distribution = list(dist = "normal", mean = 0, sd = 3),
                                 direction = "negative",
                                 tolerance = 1e-4,
                                 max_iterations = 100,
                                 beta_min = 0.001,
                                 beta_max = 1) {
  
  library(pwrss)
  
  sign <- if (direction == "negative") -1 else 1
  iterations <- 0
  lower <- beta_min
  upper <- beta_max
  
  # Binary search over |beta1|
  while ((upper - lower) > tolerance && iterations < max_iterations) {
    iterations <- iterations + 1
    mid <- (lower + upper) / 2
    
    current_power <- pwrss.z.logreg(p0 = p0, 
                                    r2.other.x = r2.other.x,
                                    alpha = alpha, 
                                    beta1 = sign * mid, 
                                    n = n,
                                    distribution = distribution,
                                    verbose = FALSE)$power
    
    if (current_power < target_power) {
      lower <- mid   # Need larger |beta1| for more power
    } else {
      upper <- mid   # Can get away with smaller |beta1|
    }
  }
  
  final_beta <- sign * (lower + upper) / 2
  final_power <- pwrss.z.logreg(p0 = p0, 
                                r2.other.x = r2.other.x,
                                alpha = alpha, 
                                beta1 = final_beta, 
                                n = n,
                                distribution = distribution,
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
                               distribution = list(dist = "normal", mean = 0, sd = 3.8))
result

# Print results
print(paste("Logit beta1 value for power = 0.5:", round(result$beta1, 5)))
print(paste("Probit beta1 value for power = 0.5:", round(result$beta1/1.6, 5))) # b_logit = 1.6*b_probit
print(paste("Probit marginal effect value for power = 0.5:", round(result$beta1/1.6*0.4, 5))) #AME <= 0.4*beta_probit
print(paste("Actual power achieved:", round(result$power, 5)))
print(paste("Iterations required:", result$iterations))

