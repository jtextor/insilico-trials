let alpha_m3 = 0.04495;
let _beta = 1.1*1e12;
let _gamma = 1/1e10;
let sigma = 2500;
let rho = 0.05;
let delta_m3 = 0.019;
let mu = 1/1e12;
let g_m3 = 1e7;
let RAISE_GAMMA = 1.0;
let LOWER_ALPHA = 1.0;

let DIAGNOSIS_THRESHOLD_m3 = 65*1e8;
let DEATH_THRESHOLD_m3 = 1e12;
let DIAGNOSED_AT_m3 = Infinity;
let DEAD_AT_m3 = Infinity;
let t_max_m3 = 365.0*10;     // simulation duration (i.e., 25 years);
let therapy_start = 1;     // delay of therapy start after diagnosis (default = day after diagnosis)

let treatment_on = 0;

function tumormodel3(t, x){
	T = x[0];
	E = x[1];

	if (T > DIAGNOSIS_THRESHOLD_m3){
		if (t < DIAGNOSED_AT_m3){
			DIAGNOSED_AT_m3 = t;
		}
	}

	if (T > DEATH_THRESHOLD_m3){
		if (t < DEAD_AT_m3){
			DEAD_AT_m3 = t;
		}
	}

	immuno_effect = (t > DIAGNOSED_AT_m3) ? RAISE_GAMMA : 1.0;
	chemo_effect = (t > DIAGNOSED_AT_m3) ? LOWER_ALPHA : 1.0;

	dxdt = [];
	dxdt.push(chemo_effect * alpha_m3 * T * ( 1 - T/_beta) - _gamma * immuno_effect * T * E);
	dxdt.push(sigma - delta_m3 * E + rho*(T*E)/(g_m3+T) - mu*E*T);
	return(dxdt);
}

function get_survival_model3(R_, raise_killing, lower_growth, diagnosis_threshold, death_threshold){ 
	x = [1, 0];

	DIAGNOSED_AT_m3 = Infinity;
	DEAD_AT_m3 = Infinity;

	alpha_m3 = R_;
	RAISE_GAMMA = raise_killing;
	LOWER_ALPHA = lower_growth;
	DIAGNOSIS_THRESHOLD_m3 = diagnosis_threshold;
	DEATH_THRESHOLD_m3 = death_threshold;

	simulated_values = rk4(tumormodel3, x, 0, 1, t_max_m3/1);

	if (DIAGNOSED_AT_m3 < t_max_m3){
		return ((DEAD_AT_m3 - DIAGNOSED_AT_m3)/30.4);
	}
	else {
		return (Infinity);
	}
}

function population_survival_model3(R_mu, R_sigma, raise_killing, chemo_effect, n){
	r_values = Array.from({length: n}, d3.randomLogNormal(R_mu, R_sigma));
	survival_values = r_values.map((e, i) => get_survival_model3(e, raise_killing, chemo_effect, 65*1e8, 1e12));
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
