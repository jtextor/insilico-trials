#include <utility>

#include "timeseries.h"


Timeseries::Timeseries()
  : Tt_{}
{ }


Timeseries::operator Timeseries::Functor(){
  return Functor(Tt_);
}


Rcpp::NumericVector Timeseries::move_timeseries_vector() {
  return std::move(Tt_);
}


_internal::TimeseriesWriter::TimeseriesWriter(Rcpp::NumericVector &Tt)
  : Tt_{Tt}
{ }


