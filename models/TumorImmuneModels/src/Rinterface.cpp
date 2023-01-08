// [[Rcpp::depends(BH)]]
#include <Rcpp.h>
using namespace Rcpp;


#include <boost/numeric/odeint.hpp>


#include "model.hpp"
#include "parameters.hpp"
#include "timeseries.hpp"
#include "util.hpp"


using namespace std;
using namespace boost::numeric::odeint;


//' Patient survival
//' 
//' Calculates survival of the patient in months with different models 
//'
//' @param RHO Tumor proliferation rate
//' @param RAISE_KILLING The multiplication factor to increase the killing rate 
//' of cytotoxic T cells as a treatment effect of immune therapy. The default 
//' value 1 indicates no treatment effect. To simulate the immune therapy effect
//' the value should be greater than 1.
//' @param LOWER_GROWTH The multiplication factor to reduce 
//' the tumor growth as a treatment effect of chemotherapy. The default 
//' value 1 indicates no treatment effect. To simulate the chemotherapy effect
//' the value should be lower than 1.
//' @param DIAGNOSIS_THRESHOLD The number of tumor cell at which cancer is diagnosed
//' @param DEATH_THRESHOLD The lethal number of tumor cell
//' @param TREATMENT_DELAY The delay between the diagnosis and start of 
//' the immune therapy in months
//' @param TREATMENT_DURATION Immune therapy duration in months
//' @param CHEMO_DELAY The delay between the diagnosis and start of 
//' the chemotherapy in months
//' @param CHEMO_DURATION Chemotherapy duration in months
//' @return The survival of a patient in months
//' @examples
//' # Model M1
//' # Get survival when no treatment is implemented using the default model parameters
//' survival <- get_survival_cpp_M1()
//' 
//' # Get survival when partial response to immune therapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M1(RAISE_KILLING=10)
//' 
//' # Get survival when complete response to immune therapy is achieved  
//' # using the default model parameters
//' survival <- get_survival_cpp_M1(RAISE_KILLING=15)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M1(LOWER_GROWTH=0.8)
//' 
//' # Get survival when complete response to chemotherapy is achieved  
//' # using the default model parameters
//' survival <- get_survival_cpp_M1(LOWER_GROWTH=0.19)
//' 
//' # Get survival when chemotherapy is followed by immune therapy  
//' # using the default model parameters
//' get_survival_cpp_M1(LOWER_GROWTH=0.5, CHEMO_DURATION=10, RAISE_KILLING=15, TREATMENT_DELAY=10, TREATMENT_DURATION=30)
//' 
//' # Model M2
//' # Get survival when no treatment is implemented using the default model parameters
//' survival <- get_survival_cpp_M2()
//' 
//' # Get survival when partial response to immune therapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M2(RAISE_KILLING=14000)
//' 
//' # Get survival when complete response to immune therapy is achieved  
//' # using the default model parameters
//' survival <- get_survival_cpp_M2(RAISE_KILLING=14500)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M2(LOWER_GROWTH_=0.5)
//' 
//' # Get survival when complete response to chemotherapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M2(LOWER_GROWTH_=0.01)
//' 
//' # Model M3
//' # Get survival when no treatment is implemented using the default model parameters
//' survival <- get_survival_cpp_M3()
//' 
//' # Get survival when partial response to immune therapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M3(RAISE_KILLING=10)
//' 
//' # Get survival when complete response to immune therapy is achieved  
//' # using the default model parameters
//' survival <- get_survival_cpp_M3(RAISE_KILLING=17)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M3(LOWER_GROWTH=0.8)
//' 
//' # Get survival when complete response to chemotherapy is achieved 
//' # using the default model parameters
//' survival <- get_survival_cpp_M3(LOWER_GROWTH=0.3)
// [[Rcpp::export]]
double get_survival_cpp_M1( double RHO = 5.0, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double DIAGNOSIS_THRESHOLD = 65e8,
  double DEATH_THRESHOLD = 1e12, double TREATMENT_DELAY=0.0,
  double TREATMENT_DURATION = 1e10, double CHEMO_DELAY=0.0,
  double CHEMO_DURATION = 1e10 ){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M1::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M1::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M1::Model tumormodel_M1(parms);

  M1::state_type x = M1::initial_condition;

  typedef runge_kutta_dopri5< M1::state_type > error_stepper_type;
  integrate_const(make_dense_output< error_stepper_type >(1.0e-6 , 1.0e-6 ),
    functor(tumormodel_M1), x, 0.0, t_max, 1.0 );

  return tumormodel_M1.months_from_diagnosis_to_death();
}


// [[Rcpp::export]]
double get_survival_cpp_M2( double RHO = 0.04495, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double DIAGNOSIS_THRESHOLD = 65e8,
  double DEATH_THRESHOLD = 1e12, double TREATMENT_DELAY=0.0,
  double TREATMENT_DURATION = 1e10, double CHEMO_DELAY=0.0,
  double CHEMO_DURATION = 1e10 ){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M2::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M2::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M2::Model tumormodel_M2(parms);

  M2::state_type x = M2::initial_condition;

  typedef runge_kutta_dopri5< M2::state_type > error_stepper_type;
  integrate_adaptive( make_controlled< error_stepper_type >( 
    1.0e-6 , 1.0e-6 ), functor(tumormodel_M2), x, 0.0, t_max, 1.0 );

  return tumormodel_M2.months_from_diagnosis_to_death();
}


// [[Rcpp::export]]
double get_survival_cpp_M3( double RHO = 0.04495, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double DIAGNOSIS_THRESHOLD = 65e8,
  double DEATH_THRESHOLD = 1e12, double TREATMENT_DELAY=0.0,
  double TREATMENT_DURATION = 1e10, double CHEMO_DELAY=0.0,
  double CHEMO_DURATION = 1e10 ){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M3::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M3::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M3::Model tumormodel_M3(parms);

  M3::state_type x = M3::initial_condition;

  typedef runge_kutta_dopri5< M3::state_type > error_stepper_type;
  integrate_adaptive( make_controlled< error_stepper_type >( 
    1.0e-6 , 1.0e-6 ), functor(tumormodel_M3), x, 0.0, t_max, 1.0 );

  return tumormodel_M3.months_from_diagnosis_to_death();
}


//' Disease trajectory
//' 
//' Simulates the disease trajectory of a single patient with different models  
//'
//' @param T_MAX The maximum treatment duration in days
//' @param immuno_effect The multiplication factor to increase the killing rate 
//' of cytotoxic T cells as a treatment effect of immune therapy. The default 
//' value 1 indicates no treatment effect. To simulate the immune therapy effect
//' the value should be greater than 1.
//' @param chemo_effect param The multiplication factor to reduce 
//' the tumor growth as a treatment effect of chemotherapy. The default 
//' value 1 indicates no treatment effect. To simulate the chemotherapy effect
//' the value should be lower than 1.
//' 
//' @return A vector that represented the tumor growth under the implemented treatment. 
//' The vector consists of 3 concatenated vectors that represent 1) time scale, 
//' 2) tumor size at a given time, 3) number of intramural T cells at a given time.
//' Transform it to a matrix with the corresponding columns using matrix(x, ncol=3, byrow=TRUE)
//' to obtain the output in a format convenient for plotting.  
//' 
//' @examples
//' # Simulates the disease trajectory when no treatment is implemented
//' t_max <- 365 * 5 # five years
//' y <- simulate_M1(t_max, 1, 1)
//' y <- matrix(y, ncol=3, byrow=TRUE) # transform to extract time scale, tumor size and intramural T cells number
//' # Visualize the disease course in a period shortly before treatment and until death
//' tumor_size_start <- 1e8
//' t_start <- which.max(y[,2] >= 1e8) - 1
//' y <- y[-(1:t_start),]
//' tumor_size_death <- 1e12
//' y <- y[y[,2] <= tumor_size_death,] 
//' day_in_month <- 30.4
//' y[,1] <- (y[,1] - min(y[,1])) / 30.4
//' # Plot the millions of tumor cells by months 
//' plot( y[,1], y[,2]/1e6, log="y", type="l", col="orange", xlab="", ylab="tumor burden (million cells)")
// [[Rcpp::export]]
NumericVector simulate_M1( double T_MAX = 120.0, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double RHO = 5.0,
  double DIAGNOSIS_THRESHOLD = 65e8, double DEATH_THRESHOLD = 1e12,
  double TREATMENT_DELAY=0.0, double TREATMENT_DURATION = 1e10,
  double CHEMO_DELAY=0.0, double CHEMO_DURATION = 1e10){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M1::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M1::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M1::Model tumormodel_M1(parms);

  M1::state_type x = M1::initial_condition;
  Timeseries write_solution_M1;

  typedef runge_kutta_dopri5< M1::state_type > error_stepper_type;
  integrate_adaptive( make_controlled< error_stepper_type >(1.0e-10 , 1.0e-6 ),
    functor(tumormodel_M1), x, 0.0, T_MAX * days_per_month, 1.0,
    functor(write_solution_M1) );

  return write_solution_M1.move_timeseries_vector();
}


// [[Rcpp::export]]
NumericVector simulate_M2( double T_MAX = 120.0, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double RHO = 0.04495,
  double DIAGNOSIS_THRESHOLD = 65e8, double DEATH_THRESHOLD = 1e12,
  double TREATMENT_DELAY=0.0, double TREATMENT_DURATION = 1e10,
  double CHEMO_DELAY=0.0, double CHEMO_DURATION = 1e10){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M2::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M2::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M2::Model tumormodel_M2(parms);

  M2::state_type x = M2::initial_condition;
  Timeseries write_solution_M2;
  
  typedef runge_kutta_dopri5< M2::state_type > error_stepper_type;
  integrate_adaptive( make_controlled< error_stepper_type >(1.0e-10 , 1.0e-6 ),
    functor(tumormodel_M2), x, 0.0, T_MAX * days_per_month, 1.0,
    functor(write_solution_M2) );

  return write_solution_M2.move_timeseries_vector();
}


// [[Rcpp::export]]
NumericVector simulate_M3( double T_MAX = 120.0, double RAISE_KILLING = 1.0,
  double LOWER_GROWTH = 1.0, double RHO = 0.04495,
  double DIAGNOSIS_THRESHOLD = 65e8, double DEATH_THRESHOLD = 1e12,
  double TREATMENT_DELAY=0.0, double TREATMENT_DURATION = 1e10,
  double CHEMO_DELAY=0.0, double CHEMO_DURATION = 1e10){

  /** CAUTION: The above values are duplicates of values in Mx::Parameters
   *           and M3::Parameters.  These values need to be kept in sync
   *           with the values in these classes.  They are duplicated to
   *           ensure Rcpp::export can parse this function's signature.
   */

  const auto parms = M3::Parameters()
    .set_rho(RHO)
    .set_raise_killing(RAISE_KILLING)
    .set_lower_growth(LOWER_GROWTH)
    .set_diagnosis_threshold(DIAGNOSIS_THRESHOLD)
    .set_death_threshold(DEATH_THRESHOLD)
    .set_treatment_delay(TREATMENT_DELAY)
    .set_treatment_duration(TREATMENT_DURATION)
    .set_chemo_delay(CHEMO_DELAY)
    .set_chemo_duration(CHEMO_DURATION);

  M3::Model tumormodel_M3(parms);

  M3::state_type x = M3::initial_condition;
  Timeseries write_solution_M3;

  typedef runge_kutta_dopri5< M3::state_type > error_stepper_type;
  integrate_adaptive( make_controlled< error_stepper_type >( 
    1.0e-10 , 1.0e-6 ), functor(tumormodel_M3), x, 0.0, T_MAX * days_per_month,
    1.0, functor(write_solution_M3) );

  return write_solution_M3.move_timeseries_vector();
}
