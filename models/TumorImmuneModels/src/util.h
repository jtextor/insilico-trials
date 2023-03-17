#ifndef UTIL_HPP
#define UTIL_HPP


#include <limits>


constexpr double days_per_month = 30.4;
constexpr double infinity = std::numeric_limits<double>::infinity();
constexpr double t_max = 365. * 10.; // Simulation duration.


// Some of our classes have an associated type that we call Functor.
// We use this to prevent copies from Boost passing stuff by value:
//
// - One class is the interface class that the end user constructs and
//   interacts with,
// - The other class contains references to data held by the first class
//   and defines some operator()(...) that functions as callback for Boost.
//
// This function is a utility function that translates from an interface
// class to its associated Functor type.
template <typename T>
typename T::Functor
functor(T& x)
{
  return typename T::Functor(x);
}


#endif /* ndef UTIL_HPP */
