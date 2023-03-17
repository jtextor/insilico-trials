#ifndef TIMESERIES_HPP
#define TIMESERIES_HPP


/** Here we define the Timeseries and the TimeseriesWriter classes.
 * They are used to boost::numeric::odeint as an observer to record
 * a timeseries resulting from integrating a system of ODEs over time.
 * Calling functor(...) on Timeseries constructs a TimeseriesWriter,
 * which in turn can be passed to boost::numeric::odeint.
 */


#include <Rcpp.h>


// Defined below.
class Timeseries;


namespace _internal {


// Functor for recording a time series resulting from numeric
// integration of a system of ODEs.
//
// This is a helper class to Timeseries.  This helper class does
// the actual writing, while Timeseries provides the interface
// and sets up the NumericVector that instances of this class
// write to.
class TimeseriesWriter
{
  // Reference to vector that we write timeseries to.
  Rcpp::NumericVector &Tt_;

  // Constructor is private, since only Timeseries needs to construct
  // instances of this class.
  TimeseriesWriter(Rcpp::NumericVector&);

  // Enable Timeseries to use the private constructor.
  friend class ::Timeseries;

public:
  // Record values during integration into NumericVector
  template <class S>
  void operator()(const S &x, double t) {
    Tt_.push_back(t);
    Tt_.push_back(x[0]);
    Tt_.push_back(x[1]);
  }
};


} // namespace _internal


// Class for recording a time series resulting from numeric
// integration of a system of ODEs.
//
// This class provides an interface for the recording of such time
// series.  boost::numeric::odeint::integrate_adaptive(...) copies its
// Observer argument, so in order to retain the recorded values we
// need to construct an instance of a helper class that has a reference
// to the timeseries where we record into.
class Timeseries
{
  // This is where the timeseries is recorded.
  Rcpp::NumericVector Tt_;
public:

  using Functor = _internal::TimeseriesWriter;
  
  Timeseries();

  // Convert to helper class -- implicitly if possible.
  operator Functor();

  // Destructively return the NumericVector with the recorded timeseries.
  Rcpp::NumericVector move_timeseries_vector();
};


#endif /* ndef TIMESERIES_HPP */
