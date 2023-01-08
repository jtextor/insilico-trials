#include "parameters.hpp"


namespace M1 {


Parameters::Parameters()
  : raise_killing_{1.0}
  , rho_{default_rho}
{ }


Parameters& Parameters::set_raise_killing(double newval) {
  raise_killing_ = newval;
  return *this;
}


Parameters& Parameters::set_rho(double newval) {
  rho_ = newval;
  return *this;
}


} // namespace M1


namespace M2 {


Parameters::Parameters()
  : lower_delta_{1.0}
  , raise_alpha_e_{1.0}
  , rho_{default_rho}
{ }


Parameters& Parameters::set_raise_killing(double newval)
{
  raise_alpha_e_ = newval;
  lower_delta_ = 1.0 / newval;
  return *this;
}


Parameters& Parameters::set_rho(double newval)
{
  rho_ = newval;
  return *this;
}


} // namespace M2


namespace M3 {


Parameters::Parameters()
  : alpha_{default_alpha}
  , raise_gamma_{1.0}
{ }


Parameters& Parameters::set_raise_killing(double newval)
{
  raise_gamma_ = newval;
  return *this;
}


Parameters& Parameters::set_rho(double newval)
{
  alpha_ = newval;
  return *this;
}


} // namespace M3
