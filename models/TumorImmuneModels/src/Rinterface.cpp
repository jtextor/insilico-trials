// [[Rcpp::depends(BH)]]
#include <Rcpp.h>
using namespace Rcpp;


#include <boost/numeric/odeint.hpp>


#include "model.h"
#include "parameters.h"
#include "timeseries.h"
#include "util.h"


using namespace std;
using namespace boost::numeric::odeint;


//' Disease Trajectories and Patient Survival
//' 
//' The functions get_survival_cpp_MX calculate survival of a simulated patient in months
//' with model MX (X=1,2, or 3), whereas the functions simulate_MX 
//' generate simulated disease trajectories (i.e., patients over time) 
//' for a single patient with different models. 
//' See Creemers et al. (2023) for full definitions of each model.
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
//' @return For the get_survival_cpp_MX functions, the
//'    survival of a patient in months. For the simulate_MX functions, a
//'    matrix representing the disease trajectory (see examples). 
//'    Caution: for the simulate_MX functions the 
//' output time resolution is _days_, not months.
//' @examples
//' # Model M1
//' # Get survival when no treatment is implemented using the default model parameters
//' get_survival_cpp_M1()
//' 
//' # Get survival when partial response to immunotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M1(RAISE_KILLING=10)
//' 
//' # Get survival when complete response to immunotherapy is achieved  
//' # using the default model parameters
//' get_survival_cpp_M1(RAISE_KILLING=20)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M1(LOWER_GROWTH=0.8)
//' 
//' # Get survival when complete response to chemotherapy is achieved  
//' # using the default model parameters
//' get_survival_cpp_M1(LOWER_GROWTH=0.19)
//' 
//' # Get survival when chemotherapy is followed by immunotherapy  
//' # using the default model parameters
//' get_survival_cpp_M1(LOWER_GROWTH=0.5, CHEMO_DURATION=10, RAISE_KILLING=15, 
//'    TREATMENT_DELAY=10, TREATMENT_DURATION=30)
//' 
//' # Model M2
//' # Get survival when no treatment is implemented using the default model parameters
//' get_survival_cpp_M2()
//' 
//' # Get survival when partial response to immunotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M2(RAISE_KILLING=14000)
//' 
//' # Get survival when complete response to immunotherapy is achieved  
//' # using the default model parameters
//' get_survival_cpp_M2(RAISE_KILLING=14500)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M2(LOWER_GROWTH=0.5)
//' 
//' # Get survival when complete response to chemotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M2(LOWER_GROWTH=0.01)
//' 
//' # Model M3
//' # Get survival when no treatment is implemented using the default model parameters
//' get_survival_cpp_M3()
//' 
//' # Get survival when partial response to immunotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M3(RAISE_KILLING=10)
//' 
//' # Get survival when complete response to immunotherapy is achieved  
//' # using the default model parameters
//' get_survival_cpp_M3(RAISE_KILLING=17)
//' 
//' # Get survival when partial response to chemotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M3(LOWER_GROWTH=0.8)
//' 
//' # Get survival when complete response to chemotherapy is achieved 
//' # using the default model parameters
//' get_survival_cpp_M3(LOWER_GROWTH=0.3)
//' @references
//' Jeroen Creemers, Ankur Ankan, Kit C.B. Roes, Gijs Schröder, Niven Mehra, Carl G. Figdor, 
//' I. Jolanda M. de Vries, and Johannes Textor (2013), In silico cancer immunotherapy trials
//' uncover the consequences of therapy-specific response patterns for clinical trial design
//' and outcome, medRxiv 2021.09.09.21263319; doi: https://doi.org/10.1101/2021.09.09.21263319
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

//' @rdname get_survival_cpp_M1
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

//' @rdname get_survival_cpp_M1
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


//' @param T_MAX The maximum treatment duration in months
//' @rdname get_survival_cpp_M1
//' 
//' @examples
//' # Simulates the disease trajectory when no treatment is implemented
//' t_max <- 12 * 5 # five years
//' y <- simulate_M1(t_max, 1, 1)
//' # Transform output to extract time, tumor size and intratumoral T cells
//' y <- matrix(y, ncol=3, byrow=TRUE) 
//' # Visualize the disease course in a period shortly before treatment and until death
//' tumor_size_start <- 1e8
//' t_start <- which.max(y[,2] >= 1e8) - 1
//' y <- y[-(1:t_start),]
//' tumor_size_death <- 1e12
//' y <- y[y[,2] <= tumor_size_death,] 
//' day_in_month <- 30.4
//' y[,1] <- (y[,1] - min(y[,1])) / 30.4
//' # Plot tumor size over time 
//' plot( y[,1], y[,2]/1e6, log="y", type="l", col="orange", 
//'     xlab="time (months)", ylab="tumor burden (million cells)")
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

//' @param T_MAX The maximum treatment duration in months
//' @rdname get_survival_cpp_M1
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

//' @param T_MAX The maximum treatment duration in months
//' @rdname get_survival_cpp_M1
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
