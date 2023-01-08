#include <cmath>

#include "modelodes.hpp"
#include "parameters.hpp"
#include "stopwatch.hpp"
#include "util.hpp"


namespace M1 {
namespace _internal {


ModelODEs::ModelODEs(const Parameters &parms, Mx::Stopwatch &stopwatch)
  : parms_{parms}
  , stopwatch_{stopwatch}
{ }


void ModelODEs::operator()(const state_type &x, state_type &dxdt, double t) {
  const double T = x[0], I = x[1], S = x[2], N = x[3];

  const bool dead = stopwatch_.update(parms_.diagnosis_threshold_,
      parms_.death_threshold_, t, T);
  
  // prevent wasting time
  if( dead || T < 1 ){
    dxdt[0] = dxdt[1] = dxdt[2] = dxdt[3] = 0;
    return;
  }

  double killing = parms_.xi * I * T / (1 + I/parms_.hI + T / parms_.hT);      // time-independent killing
  double growth = parms_.rho_;

  // Implement treatments
  if( t > stopwatch_.diagnosed_at() + parms_.treatment_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.treatment_delay_ <= parms_.treatment_duration_ ){
    killing *= parms_.raise_killing_;
  }

  if( t > stopwatch_.diagnosed_at() + parms_.chemo_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.chemo_delay_ <= parms_.chemo_duration_ ){
    growth *= parms_.lower_growth_;
  }

  if( T < 1 ){
    dxdt[0] = -T; // tumor cells
  } else{
    dxdt[0] = growth * pow( T , parms_.growth_exponent ) - killing; // tumor cells
  }
  dxdt[1] = S - parms_.delta*I;                             // TILs

  const double antigenic_signal = ( T / (parms_.g + T) );
  const double t_cell_activation = parms_.alpha * antigenic_signal * N;
  dxdt[2] = t_cell_activation + antigenic_signal * parms_.p_S * S - parms_.m_S * S; // specific T cells
  dxdt[3] = - t_cell_activation;                     // naive T cells
}


} // namespace _internal
} // namespace M1


namespace M2 {
namespace _internal {


ModelODEs::ModelODEs(const Parameters &parms, Mx::Stopwatch &stopwatch)
  : parms_{parms}
  , stopwatch_{stopwatch}
{ }


void ModelODEs::operator()(const state_type &x, state_type &dxdt, double t) {
  const double T = x[0], I = x[1], A = x[2];

  const bool dead = stopwatch_.update(parms_.diagnosis_threshold_,
      parms_.death_threshold_, t, T);

  // prevent wasting time simulating after death or clearance
  if( dead || T < 1 ){
    dxdt[0] = dxdt[1] = dxdt[2] = 0;
    return;
  }

  double raise_alpha_e_t = 1.,
    lower_delta_t = 1.;

  if( t > stopwatch_.diagnosed_at() + parms_.treatment_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.treatment_delay_ <= parms_.treatment_duration_ ){
    raise_alpha_e_t = parms_.raise_alpha_e_;
    lower_delta_t = parms_.lower_delta_;
  }
  double lower_rho_t = 1.;
  if( t > stopwatch_.diagnosed_at() + parms_.chemo_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.chemo_delay_ <= parms_.chemo_duration_ ){
    lower_rho_t = parms_.lower_growth_;
  }

  dxdt[0] = lower_rho_t * parms_.rho_ * T - parms_.xi * ( (I * T) / (1 + T/parms_.h_T) );  // Tumor cells
  dxdt[2] = parms_.alpha_A * ( T / (T + parms_.b) ) - parms_.mu_alpha * A;       // APC
  dxdt[1] = raise_alpha_e_t * parms_.alpha_e * A - lower_delta_t * parms_.delta * I;              // T cells
}


} // namespace _internal
} // namespace M2


namespace M3 {
namespace _internal {


ModelODEs::ModelODEs(const Parameters &parms, Mx::Stopwatch &stopwatch)
  : parms_{parms}
  , stopwatch_{stopwatch}
{ }


void ModelODEs::operator()(const state_type &x, state_type &dxdt, double t) {
  const double T = x[0], E = x[1];

  const bool dead = stopwatch_.update(parms_.diagnosis_threshold_,
      parms_.death_threshold_, t, T);

  // prevent wasting time simulating after death or clearance
  if( dead || T < 1 ){
    dxdt[0] = dxdt[1] = dxdt[2] = 0;
    return;
  }

  double immuno_effect = 1.;

  if( t > stopwatch_.diagnosed_at() + parms_.treatment_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.treatment_delay_ <= parms_.treatment_duration_ ){
    immuno_effect = parms_.raise_gamma_;
  }
  double chemo_effect = 1.;
  if( t > stopwatch_.diagnosed_at() + parms_.chemo_delay_ &&
      t - stopwatch_.diagnosed_at() - parms_.chemo_delay_ <= parms_.chemo_duration_ ){
    chemo_effect = parms_.lower_growth_;
  }

  dxdt[0] = chemo_effect * parms_.alpha_ * T * (1 - T/parms_.beta) - parms_.gamma * immuno_effect * T * E;  // Tumor cells
  dxdt[1] = parms_.sigma + parms_.rho*(T*E)/(parms_.g+T) - parms_.delta * E - parms_.mu * E * T; // Effector cells
}


} // namespace _internal
} // namespace M3
