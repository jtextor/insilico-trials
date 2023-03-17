#include "model.h"
#include "parameters.h"

namespace Mx {


double Model::months_from_diagnosis_to_death() const {
  if( stopwatch_.diagnosed_at() < infinity ){
    return (stopwatch_.dead_at() - stopwatch_.diagnosed_at())/days_per_month;
  } else {
    return infinity;
  }
}


} // namespace Mx


namespace M1 {


Model::Model(const M1::Parameters &parms)
  : parms_{parms}
{ }


Model::operator Model::Functor() {
  return Functor(parms_, stopwatch_);
}


} // namespace M1


namespace M2 {


Model::Model(const M2::Parameters &parms)
  : parms_{parms}
{ }


Model::operator Model::Functor() {
  return Functor(parms_, stopwatch_);
}


} // namespace M2


namespace M3 {


Model::Model(const M3::Parameters &parms)
  : parms_{parms}
{ }


Model::operator Model::Functor() {
  return Functor(parms_, stopwatch_);
}


} // namespace M3
