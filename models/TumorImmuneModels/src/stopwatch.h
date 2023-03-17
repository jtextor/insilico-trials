#ifndef STOPWATCH_HPP
#define STOPWATCH_HPP


/** Here we define the Stopwatch class.
 * It helps the Model classes keep track of times of diagnosis and death.
 */


// Namespace Mx contains classes for all three TumorImmuneModels.
namespace Mx {


// Helps TumorImmuneModels record time of diagnosis and time of death.
class Stopwatch
{
  // For interpolating times of diagnosis and death.
  double previous_t_, previous_T_;

  // Times of diagnosis and death.
  double diagnosed_at_, dead_at_;

public:
  Stopwatch();

  // Return current estimate for time of death.
  double dead_at() const;

  // Return current estimate for time of diagnosis.
  double diagnosed_at() const;

  // Call this once every integration step to get increasingly accurate
  // estimates of times of diagnosis and death.
  // Return whether tumor size exceeded death threshold.  
  bool update(double, double, double, double);

private:
  // Backward linearly interpolate the time (t) at which tumor mass (T)
  // exceeded the threshold value.
  double interpolate_time(double, double, double);
};


} // namespace Mx


#endif /* ndef STOPWATCH_HPP */
