let alpha_A = 2.0735*1e3;                             // APC activation rate
let b = 9.233*1e4;                                    // Nr of tumor cells to reach half of max activation rat
let mu_alpha = 0.2310;                                // APC death rate
let v_mel = 0.1245;                                   // Tumor cell elimination rate by T cells
let g = 6.0095*1e7;                                    // Scaling factor of tumor cell death rate
let DIAGNOSIS_THRESHOLD = 65*1e8;
let DEATH_THRESHOLD=1e12;
let DIAGNOSED_AT = Infinity;
let DEAT_AT = Infinity;
let t_max = 1825.0*5;
let TREATMNET_DURATION = Infinity;
let CHEMO_DURATION = Infinity;
let alpha_e = 0.8318;
let mu_e = 0.1777;
let gamma_mel = 0.04495;
let RAISE_alpha_e = 1.0;
let LOWER_mu_e = 1.0;
let LOWER_gamma_mel = 1.0;

let INITIAL_CONDITION = [0, 0, 1];


function tumormodel2(t, x){
	A = x[0];
	T = x[1];
	M = x[2];

	if (M > DIAGNOSIS_THRESHOLD){
		if (t < DIAGNOSED_AT){
			DIAGNOSED_AT = t;
		}
	}

	if (M > DEATH_THRESHOLD){
		if (t < DEAD_AT){
			DEAD_AT = t;
		}
	}

	if (M > DEATH_THRESHOLD || M < 1){
		dxdt = [0, 0, 0];
		return(dxdt);
	}

	raise_alpha_e_t = 1.0;
	lower_mu_e_t = 1.0;
	if ((t > DIAGNOSED_AT) && ((t-DIAGNOSED_AT) <= TREATMENT_DURATION)){
		raise_alpha_e_t = RAISE_alpha_e;
		lower_mu_e_t = LOWER_mu_e;
	}

	lower_gamma_mel_t = 1.0;
	if ((t > DIAGNOSED_AT) && (t-DIAGNOSED_AT <= CHEMO_DURATION)){
		lower_gamma_mel_t = LOWER_gamma_mel;
	}

	dxdt = [];
	dxdt.push(alpha_A * (M / (M + b) ) - mu_alpha * A);
	dxdt.push(raise_alpha_e_t * alpha_e * A - lower_mu_e_t * mu_e * T);
	dxdt.push(lower_gamma_mel_t * gamma_mel * M - v_mel * ( (T * M) / (M + g) ));
	return (dxdt);
}

function get_survival_model2(R_, raise_killing, lower_growth, diagnosis_threshold, death_threshold){
	x = INITIAL_CONDITION;
	gamma_mel = R_;
	RAISE_alpha_e = raise_killing;
	LOWER_mu_e = 1/raise_killing;

	LOWER_gamma_mel = lower_growth;
	DIAGNOSIS_THRESHOLD = diagnosis_threshold;
	DEATH_THRESHOLD = death_threshold;

	DIAGNOSED_AT = Infinity;
	DEAD_AT = Infinity;

	simulated_values = rk4(tumormodel2, x, 0, 1, t_max/1);
	if (DIAGNOSED_AT < t_max){
		return ((DEAD_AT - DIAGNOSED_AT)/30.4);
	}
	else {
		return (Infinity);
	}
}

function population_survival_model2(R_mu, R_sigma, raise_killing, chemo_effect, n){
	r_values = Array.from({length: n}, d3.randomLogNormal(R_mu, R_sigma));
	survival_values = r_values.map((e, i) => get_survival_model2(e, raise_killing, chemo_effect, 65*1e8, 1e12));
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
