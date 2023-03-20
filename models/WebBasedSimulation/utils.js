/**
 * Returns the elementwise sum of arrays x and y.
 * @param {Array} x
 * @param {Array} y
 */
function vectorAdd(x, y){
	return x.map((e, i) => e + y[i]);
}

/**
 * Returns the elementwise difference of arrays x and y.
 * @param {Array} x
 * @param {Array} y
 */
function vectorSub(x, y){
	return x.map((e, i) => e - y[i]);
}

/**
 * Returns the elementwise product of arrays x and y.
 * @param {Array} x
 * @param {Array} y
 */
function scalerMult(x, y){
	return y.map((e, i) => e * x);
}

/**
 * Returns the sum of all elements of array x.
 * @param {Array} x
 */
function array_sum(x){
	partial = 0;
	for (var i=0; i < x.length; i++){
		partial += x[i];
	}
	return partial;
}

/**
 * Compare each value of x to y. Returns true for each i if x[i] < y
 * @param {Array} x
 * @param y
 */
function vectorCompare(x, y){
	return x.map((e, i) => e > y);
}

/**
 * Compare each value of x to y. Returns true for each i if x[i] <= y
 * @param {Array} x
 * @param y
 */
function vectorCompareEqual(x, y){
	return x.map((e, i) => e >= y);
}

/**
 * Computes the Euclidean distance between points x and y
 * @param {Array} x
 * @param {Array} y
 */
function distance(x, y){
	sq_diff = vectorSub(x, y).map((e, i) => e**2);
	return Math.sqrt(array_sum(sq_diff));
}

/**
 * Compute the median of the a sorted array `sorted_num`
 */
function median(sorted_num) {
    const middle = Math.floor(sorted_num.length / 2);

    if (sorted_num.length % 2 === 0) {
        return (sorted_num[middle - 1] + sorted_num[middle]) / 2;
    }

    return sorted_num[middle];
}

/**
 * Compute the mean of the array `numbers` while replacing Infinite values with `max`.
 */
function mean(numbers, max) {
    return Math.round((array_sum(numbers.map((e, i) => (e == Infinity) ? max : e)) / numbers.length) * 100) / 100;
}


/**
 * Appoximate the value of y in the differential equation dy/dt at t=(start+stepSize*steps) given value at t0 using Runge-Kutta method.
 * @param {function} f: Differential equation which returns the value of dy/dt
 * @param {Array} y0: The value of the function at t0. 
 * @param {float} t0: The initial value of t.
 * @param {float} step_size: The step size to take in each iteration.
 * @param {int} n_steps: Number of steps.
 */
function rk4(f, y0, t0, step_size, n_steps){
	t = t0;
	i = 0;
	y_history = [y0];

	while(i < n_steps){
		y = [];
		// k1 = f(t, y0)
		k1 = f(t, y0);
		// k2 = f(t + 1/2 dt, y0 + 1/2 dt k1)
		k2 = f(t + (0.5 * step_size), vectorAdd(y0, scalerMult(0.5 * step_size, k1)));
		// k3 = f(t + 1/2 dt, y0 + 1/2 dt k2)
		k3 = f(t + (0.5 * step_size), vectorAdd(y0, scalerMult(0.5 * step_size, k2)));
		// k4 = f(t + dt, y0 + dt k3)
		k4 = f(t + step_size, vectorAdd(y0, scalerMult(step_size, k3)));

		for(k=0; k<y0.length; k++){
			y.push(y0[k] + (step_size*(k1[k] + (2 * k2[k]) + (2 * k3[k]) + k4[k]) / 6));
		}

		y0 = y;
		y_history.push(y0);

		t += step_size;
		i++;
	}
	return (y_history);
};

function rk4_boost(f, y0, t0, step_size, n_steps){
	t = t0;
	i = 0;
	y_history = [y0];

	dt = step_size;
	dh = step_size/2;
	th = t + dh;

	while(i < n_steps){
		// e1 = y_n
		e1 = y0;
		// e2 = y_n + h/2 f(t_n, e1)
		e2 = vectorAdd(y0, scalerMult(dh, f(t, e1)));
		// e3 = y_n + h/2 f(t_n + h/2, e2)
		e3 = vectorAdd(y0, scalerMult(dh, f(t+dh, e2)));
		// e4 = y_n + h f(t_n + h/2, e3)
		e4 = vectorAdd(y0, scalerMult(dt, f(t+dh, e3)));

		k1 = scalerMult(1/6, f(t, e1));
		k2 = scalerMult(1/3, f(t+dh, e2));
		k3 = scalerMult(1/3, f(t+dh, e3));
		k4 = scalerMult(1/6, f(t+dt, e4));

		y = vectorAdd(y0, scalerMult(dt, vectorAdd(vectorAdd(vectorAdd(k1, k2), k3), k4)));

		y0 = y;
		y_history.push(y0);

		t += step_size;
		i++;
	}
	return (y_history);
}

function get_simulation_fn(model_id){
	if (model_id == "model1"){
		return population_survival_model1;
	}
	else if (model_id == "model2"){
		return population_survival_model2;
	}
	else if (model_id == "model3"){
		return population_survival_model3;
	}
}

function set_model_defaults(model_id){
	/* Set R mean */
	document.getElementById("R_mu").min = RMEAN_RANGE['min'][model_id]
	document.getElementById("R_mu").max = RMEAN_RANGE['max'][model_id]
	document.getElementById("R_mu").value = DEFAULT_VALUES[model_id]['rmean']
	document.getElementById("R_mu_value").value = DEFAULT_VALUES[model_id]['rmean']
	R_mu = DEFAULT_VALUES[model_id]['rmean']

	/* Set R sd */
	document.getElementById("R_sigma").min = RSD_RANGE['min'][model_id]
	document.getElementById("R_sigma").max = RSD_RANGE['max'][model_id]
	document.getElementById("R_sigma").value = DEFAULT_VALUES[model_id]['rsd']
	document.getElementById("R_sigma_value").value = DEFAULT_VALUES[model_id]['rsd']
	R_sigma = DEFAULT_VALUES[model_id]['rsd']

	/* Set immunotherapy effect */
	document.getElementById("raise_killing").min = IMM_EFFECT_RANGE['min'][model_id]
	document.getElementById("raise_killing").max = IMM_EFFECT_RANGE['max'][model_id]
	document.getElementById("raise_killing").value = DEFAULT_VALUES[model_id]['imm_effect']
	document.getElementById("imm_effect_value").value = DEFAULT_VALUES[model_id]['imm_effect']
	raise_killing = DEFAULT_VALUES[model_id]['imm_effect']

	/* Set chemotherepy effect */
	document.getElementById("chemo_effect").min = CHEMO_EFFECT_RANGE['min'][model_id]
	document.getElementById("chemo_effect").max = CHEMO_EFFECT_RANGE['max'][model_id]
	document.getElementById("chemo_effect").value = DEFAULT_VALUES[model_id]['chemo_effect']
	document.getElementById("chemo_effect_value").value = DEFAULT_VALUES[model_id]['chemo_effect']
	chemo_effect = DEFAULT_VALUES[model_id]['chemo_effect']

	/* Set chemotherepy effect */
	document.getElementById("n_patients").min = PATIENT_RANGE['min'][model_id]
	document.getElementById("n_patients").max = PATIENT_RANGE['max'][model_id]
	document.getElementById("n_patients").value = DEFAULT_VALUES[model_id]['n_patients']
	document.getElementById("n_patients_value").value = DEFAULT_VALUES[model_id]['n_patients']
	n_patients = DEFAULT_VALUES[model_id]['n_patients']
}
