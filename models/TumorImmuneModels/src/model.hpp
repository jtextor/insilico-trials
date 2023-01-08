#ifndef MODEL_HPP
#define MODEL_HPP


/** Here we define four Model classes, each in their own namespace.
 * In namespace Mx is the parent class to the other three.
 * Namespaces M{1,2,3} contain the other three; one class per TumorImmuneModel.
 * These classes are an interface to the ODEs.
 * They can be constructed from an instance of their respective Parameter classes.
 * Calling functor(...) on them constructs an instance of the respective
 * ModelODEs class, which can be passed on to boost::numeric::odeint functions.
 */


#include "modelodes.hpp"
#include "stopwatch.hpp"
#include "util.hpp"


// Namespace Mx contains classes for all three TumorImmuneModels.
namespace Mx {


// Base class for the three TumorImmuneModels.
// Defines the stopwatch_ field, which all three TumorImmuneModels
// need.
class Model
{
protected:
  Stopwatch stopwatch_;

  // Only needs to be constructed by derived classes.
  Model() = default;

public:
  // Run after integration to obtain result for get_survival_cpp_Mx(...)
  double months_from_diagnosis_to_death() const;
};


} // namespace Mx


// Namespace M1 contains classes for TumorImmuneModel M1.
namespace M1 {


// Forward declarations.
class Parameters;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Class for passing as a system to boost::numeric::odeint::integrate_*(...),
// expressing the M1 system of ODEs.
//
// This class provides an interface for constructing such a system from
// model parameters, but does not compute derivatives itself.  In order
// for us to be able to observe times of diagnosis and death after
// integration, we need to sidestep a copy.  We do so by converting an
// instance of Model to an instance of ModelODEs -- a related class that
// *does* compute the ODEs and contains references to values contained
// here in the Model class.
class Model : public Mx::Model
{
  // Parameters of the model.
  const M1::Parameters &parms_;

public:

  using Functor = _internal::ModelODEs;

  // Construct from a Parameters object expressing the parameter values
  // for this instance of the model.  Different instances may have
  // different values for their parameters.
  Model(const M1::Parameters&);

  // Convert to ModelODEs -- the class that actually computes the system
  // of ODEs and carries a reference to the stopwatch_ field.
  operator Functor();
};


} // namespace M1


// Namespace M2 contains classes for TumorImmuneModel M2.
namespace M2 {


// Forward declarations.
class Parameters;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Class for passing as a system to boost::numeric::odeint::integrate_*(...),
// expressing the M2 system of ODEs.
//
// This class provides an interface for constructing such a system from
// model parameters, but does not compute derivatives itself.  In order
// for us to be able to observe times of diagnosis and death after
// integration, we need to sidestep a copy.  We do so by converting an
// instance of Model to an instance of ModelODEs -- a related class that
// *does* compute the ODEs and contains references to values contained
// here in the Model class.
class Model : public Mx::Model
{
  // Parameters of the model.
  const M2::Parameters &parms_;

public:

  using Functor = _internal::ModelODEs;

  // Construct from a Parameters object expressing the parameter values
  // for this instance of the model.  Different instances may have
  // different values for their parameters.
  Model(const M2::Parameters&);

  // Convert to ModelODEs -- the class that actually computes the system
  // of ODEs and carries a reference to the stopwatch_ field.
  operator Functor();
};


} // namespace M2


// Namespace M3 contains classes for TumorImmuneModel M3.
namespace M3 {


// Forward declarations.
class Parameters;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Class for passing as a system to boost::numeric::odeint::integrate_*(...),
// expressing the M3 system of ODEs.
//
// This class provides an interface for constructing such a system from
// model parameters, but does not compute derivatives itself.  In order
// for us to be able to observe times of diagnosis and death after
// integration, we need to sidestep a copy.  We do so by converting an
// instance of Model to an instance of ModelODEs -- a related class that
// *does* compute the ODEs and contains references to values contained
// here in the Model class.
class Model : public Mx::Model
{
  // Parameters of the model.
  const M3::Parameters &parms_;

public:

  using Functor = _internal::ModelODEs;

  // Construct from a Parameters object expressing the parameter values
  // for this instance of the model.  Different instances may have
  // different values for their parameters.
  Model(const M3::Parameters&);

  // Convert to ModelODEs -- the class that actually computes the system
  // of ODEs and carries a reference to the stopwatch_ field.
  operator Functor();
};


} // namespace M3


#endif /* ndef MODEL_HPP */
