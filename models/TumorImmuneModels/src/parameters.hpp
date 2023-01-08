#ifndef PARAMETERS_HPP
#define PARAMETERS_HPP


/** Here we define four-ish Parameter classes, each in their own namespace.
 * In namespace Mx is a templated parent class to the other three.
 * It is templated to enable method chaining via the curiously recurring 
 * template pattern.
 * Namespaces M{1,2,3} contain the other three; one class per TumorImmuneModel.
 * These classes represent parameters, adjustable or otherwise, for each of
 * the three TumorImmuneModels.
 * An instance of Parameter can be used to construct a corresponding Model
 * instance.
 */


#include <algorithm>

#include "util.hpp"


// For code that applies to all three TumorImmuneModels.
namespace Mx {


// Parameter values for all three TumorImmuneModels.  Parameter classes
// for all three TumorImmuneModels subclass from this one to inherit
// the parameters defined in this class.
// Curiously recurring template pattern.
template <typename T>
class Parameters
{
  // User-requested death threshold. Externally visible death threshold
  // is held at either this value or the diagnosis threshold, whichever
  // is greater.
  double target_death_threshold_;

protected:
  // Externally settable parameters.
  double
    lower_growth_, // multiplicative factor for tumor growth to simulate chemotherapy
    diagnosis_threshold_, // tumor size at which diagnosis occurs
    death_threshold_, // tumor size at which death occurs
    treatment_delay_, // months between diagnosis and start imm. therapy
    treatment_duration_, // No. months that imm. therapy is sustained
    chemo_delay_, // months between diagnosis and start chemotherapy
    chemo_duration_; // No. months that chemotherapy is sustained
  
public:
  // Default values for externally settable parameters.
  static constexpr double
    default_diagnosis_threshold = 65e8,
    default_death_threshold = 1e12,
    default_treatment_duration = 1e10,
    default_chemo_duration = 1e10;

  // Constructor with default values for the settable parameters.
  Parameters()
    : target_death_threshold_{default_diagnosis_threshold}
    , lower_growth_{1.0}
    , diagnosis_threshold_{default_diagnosis_threshold}
    , death_threshold_{default_death_threshold}
    , treatment_delay_{0.0}
    , treatment_duration_{default_treatment_duration * days_per_month}
    , chemo_delay_{0.0}
    , chemo_duration_{default_chemo_duration * days_per_month}
  { }

  // Methods for changing parameter values from their defaults.
  // Method chaining.

  T& set_death_threshold(double newval) {
    target_death_threshold_ = newval;
    // Maintain externally visible death threshold at the greater of the
    // two values of diagnosis threshold and user-requested (target) death
    // threshold.
    death_threshold_ = std::max(diagnosis_threshold_, target_death_threshold_);
    return *reinterpret_cast<T*>(this);
  }

  T& set_diagnosis_threshold(double newval) {
    diagnosis_threshold_ = newval;
    // Maintain externally visible death threshold at the greater of the
    // two values of diagnosis threshold and user-requested (target) death
    // threshold.
    death_threshold_ = std::max(diagnosis_threshold_, target_death_threshold_);
    return *reinterpret_cast<T*>(this);
  }

  T& set_lower_growth(double newval) {
    lower_growth_ = newval;
    return *reinterpret_cast<T*>(this);
  }

  T& set_treatment_delay(double newval) {
    treatment_delay_ = newval * days_per_month;
    return *reinterpret_cast<T*>(this);
  }

  T& set_treatment_duration(double newval) {
    treatment_duration_ = newval * days_per_month;
    return *reinterpret_cast<T*>(this);
  }

  T& set_chemo_delay(double newval) {
    chemo_delay_ = newval * days_per_month;
    return *reinterpret_cast<T*>(this);
  }

  T& set_chemo_duration(double newval) {
    chemo_duration_ = newval * days_per_month;
    return *reinterpret_cast<T*>(this);
  }
};


} // namespace Mx


// Namespace M1 contains classes for TumorImmuneModel M1.
namespace M1 {


// Forward declarations.
class Model;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Parameters for the TumorImmuneModel M1.
// Curiously recurring template pattern.
class Parameters : public Mx::Parameters< M1::Parameters >
{
  // Externally settable parameters -- other than the ones in
  // Mx::Parameters, which are also supported here.
  double raise_killing_; // multiplicative factor for T cell killing to simulate imm. therapy
  double rho_; // tumor growth rate

public:
  friend class M1::Model;
  friend class M1::_internal::ModelODEs;

  // Parameters that stay the same between runs.
  static constexpr double
    default_rho = 5.0, // tumor growth rate
    alpha = 0.0025, // priming rate
    delta = 0.019, // death rate immune cells
    xi = 0.001, // T cell killing rate
    g = 1e7, // Michaelis constant for antigen presentation
    hI = 571, // Michaelis constant for T cell-dependent killing saturation
    hT = 571, // Michaelis constant for tumor-dependent killing saturation
    p_S = 1., // T cell proliferation rate
    m_S = 1.,  // T cell migration rate
    growth_exponent = 3./4.;

  // Constructor with default values for the settable parameters.
  Parameters();

  // Set rho to a value other than its default.
  // Method chaining.
  Parameters& set_raise_killing(double);
  Parameters& set_rho(double);
};


} // namespace M1



// Namespace M2 contains classes for TumorImmuneModel M2.
namespace M2 {


// Forward declarations.
class Model;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Parameters for the TumorImmuneModel M2.
// Curiously recurring template pattern.
class Parameters : public Mx::Parameters< M2::Parameters >
{
  // Externally settable parameters -- other than the ones in
  // Mx::Parameters, which are also supported here.
  double lower_delta_; // multiplicative factor for T cell elimination to simulate imm. therapy  
  double raise_alpha_e_; // multiplicative factor for T cell killing to simulate imm. therapy
  double rho_; // tumor growth rate

public:
  friend class M2::Model;
  friend class M2::_internal::ModelODEs;

  // Parameters that stay the same between runs.
  static constexpr double
    default_rho = 0.04495, // tumor growth rate
    alpha_e = 0.8318, // T cell activation rate
    alpha_A = 2.0735e3, // APC activation rate
    delta = 0.1777, // T cell elimination rate
    gamma_mel = 0.1245, // Tumor elimination rate by T cells
    mu_alpha = 0.2310, // APC death rate
    b = 9.233e4, // Michaelis constant for tumor-dependent APC activation
    h_T = 6.0095e7, // Scaling factor of tumor cell death rate
    xi = gamma_mel / h_T; // effective "xi" as it would be in our model

  // Constructor with default values for the settable parameters.
  Parameters();

  // Set rho to a value other than its default.
  // Method chaining.
  Parameters& set_raise_killing(double);
  Parameters& set_rho(double);
};


} // namespace M2


// Namespace M3 contains classes for TumorImmuneModel M3.
namespace M3 {


// Forward declarations.
class Model;
namespace _internal {
    class ModelODEs;
} // namespace _internal


// Parameters for the TumorImmuneModel M3.
// Curiously recurring template pattern.
class Parameters : public Mx::Parameters< M3::Parameters >
{
  // Externally settable parameters -- other than the ones in
  // Mx::Parameters, which are also supported here.
  double alpha_; // tumor growth rate
  double raise_gamma_; // multiplicative factor for T cell killing to simulate imm. therapy

public:
  friend class M3::Model;
  friend class M3::_internal::ModelODEs;

  // Parameters that stay the same between runs.
  static constexpr double
    default_alpha = 0.04495, // tumor growth rate
    beta = 1.1e12, // maximum number of tumor cells the body can sustain
    gamma = 1e-10, // T cell killing rate
    delta = 0.019, // T cell death rate
    mu = 1e-12, // T cell exhaustion by tumor cells rate
    rho = 0.05, // maximal T cell proliferation rate from activation
    sigma = 2.0735e3, // T cell influx
    g = 1e7; // Michaelis constant for antigen presentation

  // Constructor with default values for the settable parameters.
  Parameters();

  // Set rho to a value other than its default.
  // Builder pattern.
  Parameters& set_raise_killing(double);
  Parameters& set_rho(double);
};


} // namespace M3


#endif /* ndef PARAMETERS_HPP */
