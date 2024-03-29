#' 
#' @useDynLib CPGLIB
#' @importFrom Rcpp sourceCpp
#' 
#' 
#' @importFrom stats coef predict
#' 
#' @title Generalized Linear Models via Proximal Gradients
#' 
#' @description \code{ProxGrad} computes the coefficients for generalized linear models using proximal gradients.
#' 
#' @param x Design matrix.
#' @param y Response vector.
#' @param glm_type Description of the error distribution and link function to be used for the model. Must be one of "Linear" or
#' "Logistic" . Default is "Linear".
#' @param include_intercept Argument to determine whether there is an intercept. Default is TRUE.
#' @param alpha_s Elastic net mixing parmeter. Default is 3/4.
#' @param lambda_sparsity Sparsity tuning parameter value.
#' @param tolerance Convergence criteria for the coefficients. Default is 1e-8.
#' @param max_iter Maximum number of iterations in the algorithm. Default is 1e5.
#' 
#' @return An object of class ProxGrad.
#' 
#' @export
#' 
#' @author Anthony-Alexander Christidis, \email{anthony.christidis@stat.ubc.ca}
#' 
#' @seealso \code{\link{coef.ProxGrad}}, \code{\link{predict.ProxGrad}}
#' 
#' @examples 
#' \donttest{
#' # Data simulation
#' set.seed(1)
#' n <- 50
#' N <- 2000
#' p <- 1000
#' beta.active <- c(abs(runif(p, 0, 1/2))*(-1)^rbinom(p, 1, 0.3))
#' # Parameters
#' p.active <- 100
#' beta <- c(beta.active[1:p.active], rep(0, p-p.active))
#' Sigma <- matrix(0, p, p)
#' Sigma[1:p.active, 1:p.active] <- 0.5
#' diag(Sigma) <- 1
#' 
#' # Train data
#' x.train <- mvnfast::rmvn(n, mu = rep(0, p), sigma = Sigma) 
#' prob.train <- exp(x.train %*% beta)/
#'               (1+exp(x.train %*% beta))
#' y.train <- rbinom(n, 1, prob.train)
#' # Test data
#' x.test <- mvnfast::rmvn(N, mu = rep(0, p), sigma = Sigma)
#' prob.test <- exp(x.test %*% beta)/
#'              (1+exp(x.test %*% beta))
#' y.test <- rbinom(N, 1, prob.test)
#' 
#' # ProxGrad - Single Group
#' proxgrad.out <- ProxGrad(x.train, y.train,
#'                          glm_type = "Logistic",
#'                          include_intercept = TRUE,
#'                          alpha_s = 3/4,
#'                          lambda_sparsity = 0.01, 
#'                          tolerance = 1e-5, max_iter = 1e5)
#' 
#' # Predictions
#' proxgrad.prob <- predict(proxgrad.out, newx = x.test, type = "prob")
#' proxgrad.class <- predict(proxgrad.out, newx = x.test, type = "class")
#' plot(prob.test, proxgrad.prob, pch = 20)
#' abline(h = 0.5,v = 0.5)
#' mean((prob.test-proxgrad.prob)^2)
#' mean(abs(y.test-proxgrad.class))
#' 
#' }
#' 

ProxGrad <- function(x, y, 
                     glm_type = c("Linear", "Logistic")[1], 
                     include_intercept=TRUE, 
                     alpha_s = 3/4,
                     lambda_sparsity, 
                     tolerance = 1e-8, max_iter = 1e5){
  
  # Check response data
  y <- Check_Response(y, glm_type)
  
  # Check data
  Check_Data_ProxGrad(x, y,
                      glm_type,
                      alpha_s, 
                      lambda_sparsity,
                      tolerance, max_iter)
  
  # Shuffling the data
  n <- nrow(x)
  random.permutation <- sample(1:n, n)
  x.permutation <- x[random.permutation, ]
  y.permutation <- y[random.permutation]
  
  # Setting the model type
  type.cpp <- switch(glm_type,
                     "Linear" = 1,
                     "Logistic" = 2)
  
  # Setting to include intercept parameter for CPP computation
  include_intercept.cpp <- sum(include_intercept)
  
  # Source code computation
  ProxGrad.out <- ProxGrad_Main(x.permutation, y.permutation, 
                                type.cpp, 
                                include_intercept.cpp, 
                                alpha_s,
                                lambda_sparsity,
                                tolerance, max_iter)
  
  # # Object construction
  ProxGrad.out <- construct.ProxGrad(ProxGrad.out, match.call(), glm_type, lambda_sparsity)
  
  # Return source code output
  return(ProxGrad.out)
}


