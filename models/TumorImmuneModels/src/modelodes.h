#ifndef MODELODES_HPP
#define MODELODES_HPP


/** Here we define three ModelODEs classes, each in their own namespace.
 * Namespaces M{1,2,3} contain these three; one class per TumorImmuneModel.
 * These classes are functors expressing the three systems of ODEs, and as
 * such can be passed on to boost::numeric::odeint functions.
 * They are constructed from calling functor(...) on an instance of their
 * respective Model class.
 */


#include <boost/array.hpp>


// Namespace Mx contains classes for all three TumorImmuneModels.
namespace Mx {

// Forward declaration.
class Stopwatch;

} // namespace Mx


// Namespace M1 contains classes for TumorImmuneModel M1.
namespace M1 {

// Forward declarations.
class Model;
class Parameters;


using state_type = boost::array< double , 4 >;

// Initial state for the simulations.
constexpr state_type initial_condition = {{ 1, 0, 0., 1e6 }};


namespace _internal {


// Functor expressing the tumor model M1 system of ODEs with settable
// parameters.
//
// This class is a helper class to Model.  This class does the actual
// computing of the system of ODEs, while Model merely provides an
// interface and sets up the Stopwatch instance that ModelODEs uses.
class ModelODEs
{
  // Parameters of the model.
  const M1::Parameters &parms_;

  // Used to record times of death and diagnosis.
  Mx::Stopwatch &stopwatch_;

  // Only Model needs to initialize instances of this helper.
  ModelODEs(const M1::Parameters&, Mx::Stopwatch&);

public:

  // Tumor model M1 as a system of ODEs.
  void operator()(const state_type&, state_type&, double);

  // Ensure that Model can call the private constructor.
  friend class M1::Model;
};


} // namespace _internal
} // namespace M1



// Namespace M2 contains classes for TumorImmuneModel M2.
namespace M2 {

// Forward declarations.
class Model;
class Parameters;


using state_type = boost::array< double , 3 >;

// Initial state for the simulations.
constexpr state_type initial_condition = {{ 1, 0, 0. }};


namespace _internal {


// Functor expressing the tumor model M2 system of ODEs with settable
// parameters.
//
// This class is a helper class to Model.  This class does the actual
// computing of the system of ODEs, while Model merely provides an
// interface and sets up the Stopwatch instance that ModelODEs uses.
class ModelODEs {
  // Parameters of the model.
  const M2::Parameters &parms_;

  // Used to record times of death and diagnosis.
  Mx::Stopwatch &stopwatch_;

  // Only Model needs to initialize instances of this helper.
  ModelODEs(const M2::Parameters&, Mx::Stopwatch&);

public:

  // Tumor model M2 as a system of ODEs.
  void operator()(const state_type&, state_type&, double);

  // Ensure that Model can call the private constructor.
  friend class M2::Model;
};


} // namespace _internal
} // namespace M2


// Namespace M3 contains classes for TumorImmuneModel M3.
namespace M3 {


// Forward declarations.
class Model;
class Parameters;


using state_type = boost::array< double , 2 >;

// Initial state for the simulations.
constexpr state_type initial_condition = {{ 1.0, 0.0 }};


namespace _internal {


// Functor expressing the tumor model M3 system of ODEs with settable
// parameters.
//
// This class is a helper class to Model.  This class does the actual
// computing of the system of ODEs, while Model merely provides an
// interface and sets up the Stopwatch instance that ModelODEs uses.
class ModelODEs {
  // Parameters of the model.
  const M3::Parameters &parms_;

  // Used to record times of death and diagnosis.
  Mx::Stopwatch &stopwatch_;

  // Only Model needs to initialize instances of this helper.
  ModelODEs(const M3::Parameters&, Mx::Stopwatch&);

public:

  // Tumor model M3 as a system of ODEs.
  void operator()(const state_type&, state_type&, double);

  // Ensure that Model can call the private constructor.
  friend class M3::Model;
};


} // namespace _internal
} // namespace M3


#endif /* ndef MODELODES_HPP */
