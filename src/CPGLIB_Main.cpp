/*
* ===========================================================
* File Type: CPP
* File Name: CPGLIB_Main.cpp
* Package Name: CPGLIB
*
* Created by Anthony-A. Christidis.
* Copyright � Anthony-A. Christidis. All rights reserved.
* ===========================================================
*/

#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

#include "config.h"

#include "CPGLIB.hpp" 

// [[Rcpp::export]]
Rcpp::List CPGLIB_Main(arma::mat & x, arma::vec & y,  
                       arma::uword & type, 
                       arma::uword & G,
                       arma::uword & include_intercept, 
                       double & alpha_s, double & alpha_d,
                       double & lambda_sparsity, double & lambda_diversity,
                       arma::uword & balanced_cycling,
                       arma::uword & acceleration,
                       arma::uword & permutate_search,
                       double & tolerance, arma::uword & max_iter){
  
  CPGLIB model = CPGLIB(x, y, 
                        type, 
                        G,
                        include_intercept, 
                        alpha_s, alpha_d,
                        lambda_sparsity, lambda_diversity,
                        permutate_search,
                        acceleration, 
                        tolerance, max_iter);
  
  // Computing coefficients
  if(balanced_cycling)
    model.Cycle_Groups_Balanced_Grid(); else
      model.Cycle_Groups_Grid();
  
  // Output formatting
  Rcpp::List output;
  output["Intercept"] = model.Get_Intercept_Scaled();
  output["Betas"] = model.Get_Coef_Scaled();
  output["Objective"] = model.Get_Objective_Value();
  return(output);
}