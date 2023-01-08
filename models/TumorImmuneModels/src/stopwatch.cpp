#include "stopwatch.hpp"
#include "util.hpp"


namespace Mx {


Stopwatch::Stopwatch()
  : previous_t_{0.0}
  , previous_T_{0.0}
  , diagnosed_at_{infinity}
  , dead_at_{infinity}
{ }


double Stopwatch::dead_at() const {
  return dead_at_;
}


double Stopwatch::diagnosed_at() const {
  return diagnosed_at_;
}


double Stopwatch::interpolate_time(double threshold_value, double t, double T) {
  const double tick_duration = t - previous_t_;
  const double threshold_tumordiff = threshold_value - previous_T_;
  const double tick_tumordiff = T - previous_T_;

  return previous_t_ + tick_duration*threshold_tumordiff/tick_tumordiff;
}


bool Stopwatch::update(double diagnosis_threshold, double death_threshold,
    double t, double T) {
  // Set time of diagnosis or death.
  // Interpolate after exceeding threshold to obtain more accurate estimate.
  if( T > diagnosis_threshold ){
    if( t < diagnosed_at_ ){
      diagnosed_at_ = interpolate_time(diagnosis_threshold, t, T);
    }
  }
  if( T > death_threshold ){
    if( t < dead_at_ ){
      dead_at_ = interpolate_time(death_threshold, t, T);
    }
    return true;
  }

  // Update previous time and tumor size for interpolating times of diagnosis and death.    
  previous_t_ = t;
  previous_T_ = T;
  return false;
}


} // namespace Mx
