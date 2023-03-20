const alpha = 0.0025       // priming rate
const delta = 0.019        // death rate immune cells

const hI = 571             // Michaelis constant
const hT = 571             // Michaelis constant

xi = 0.001                 // default killing rate immune cells
R_R_0 = 5                  // initial growth rate tumor
R_R_1 = R_R_0              // final growth rate tumor

GROWTH_EXPONENT = 3.0/4.0

STOCHASTIC_KILLING = 0
STOCHASTIC_GROWTH = 0

DIAGNOSIS_THRESHOLD = 65*1e8
DEATH_THRESHOLD = 1e12
DIAGNOSED_AT = Infinity
DEAD_AT = Infinity
RAISE_KILLING = 1.0         // multiplication factor of killing rate by imm. therapy
LOWER_GROWTH = 1.0          // multiplication factor of growth rate by chemotherapy
TREATMENT_DURATION = Infinity
CHEMO_DURATION = Infinity
IMMUNO_START = 0
KILLING_SD = 0
GROWTH_SD = 0
CHEMO_START = 0

DRIFT_XI = 0
DRIFT_R = 0

t_max = 5 * 365.0

seed = 42
GROWTH_RATE_DECAY_RATE = 0    // decay rate of tumor growth

function tumormodel1(t, x){
	T = x[0];
	I = x[1];
	S = x[2];
	N = x[3];

	t_cell_activation = alpha * ( T / (1e7 + T) ) * N;

	if (T > DIAGNOSIS_THRESHOLD){
		if (t < DIAGNOSED_AT){
			DIAGNOSED_AT = t;
		}
	}

	if (T > DEATH_THRESHOLD){
		if (t < DEAD_AT){
			DEAD_AT = t;
		}
	}

	killing = xi * I * (T / ( 1 + I/hI + T/hT ));
	growth = (R_R_0 * (t_max-t) + R_R_1*t)/t_max;
 
        // Start immunotherapy if: one day after diagnosis, a treatment effect is set (RAISE_KILLING),
        // and time is within treatment duration
	if ( (t > (DIAGNOSED_AT+1)) && (RAISE_KILLING != 1.0) && (t >= (DIAGNOSED_AT + IMMUNO_START)) && (t <= (DIAGNOSED_AT + IMMUNO_START+TREATMENT_DURATION)) ){
		killing *= RAISE_KILLING;
	}

        // Start chemotherapy if: one day after diagnosis, a treatment effect is set (LOWER_GROWTH),
        // and time is within treatment duration
    	if( (t > (DIAGNOSED_AT+1)) && (LOWER_GROWTH != 1.0) && (t >= (DIAGNOSED_AT + CHEMO_START) ) && (t <= (DIAGNOSED_AT + CHEMO_START + CHEMO_DURATION)) ){
        	growth *= LOWER_GROWTH;
	}

	dxdt = []
	if ( T < 1){
		dxdt.push(-T);
	}
	else{
		dxdt.push(growth * Math.pow(T, GROWTH_EXPONENT) - killing);
	}

	dxdt.push(S - delta*I);           // TILs
	dxdt.push(t_cell_activation);     // specific T cells
	dxdt.push(- t_cell_activation);   // naive T cells

	return (dxdt)
}

function get_survival_model1(R, raise_killing, chemo_effect, diagnosis_threshold, death_threshold){
	R_R_0 = R;
	RAISE_KILLING = raise_killing;
	LOWER_GROWTH = chemo_effect;
	DIAGNOSED_AT = Infinity;
	DEAD_AT = Infinity;
	DIAGNOSIS_THRESHOLD = diagnosis_threshold;
	DEATH_THRESHOLD = death_threshold;

	x = [1.0, 0.0, 0.0, 1e6];
	simulated_values = rk4(tumormodel1, x, 0, 1, t_max/1);
	if (DIAGNOSED_AT < t_max){
		return ((DEAD_AT - DIAGNOSED_AT)/30.4);
	}
	else {
		return (Infinity);
	}
}

function population_survival_model1(R_mu, R_sigma, raise_killing, chemo_effect, n){
	r_values = Array.from({length: n}, d3.randomLogNormal(R_mu, R_sigma));
	survival_values = r_values.map((e, i) => get_survival_model1(e, raise_killing, chemo_effect, 65*1e8, 1e12));
	return(survival_values);
}

// function prop_survival(R_mu, R_sigma, raise_killing, n){
// 	survival_values = population_survival(R_mu, R_sigma, raise_killing, n);
// 	p_survival = [];
// 	t = 0;
// 	max_t = 24;
// 	while (t <= max_t){
// 		p_survival.push([t, (array_sum(vectorCompare(survival_values, t))/survival_values.length)]);
// 		t += 0.1;
// 	}
// 	return (p_survival);
// }
