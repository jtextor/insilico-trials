const MAX_X_VALUE = 25; // Max time in months to plot
const NO_AT_RISK_TIMEPOINTS = [0, 3, 6, 9, 12, 15, 18, 21, 24]; // Time-points for which to calculate no at risk

const DEFAULT_VALUES = {'model1': {'rmean': 5, 'rsd': 1, 'imm_effect': 1, 'chemo_effect': 1, 'n_patients': 100},
			'model2': {'rmean': -3, 'rsd': 1, 'imm_effect': 1, 'chemo_effect': 1, 'n_patients': 100},
			'model3': {'rmean': -3, 'rsd': 1, 'imm_effect': 1, 'chemo_effect': 1, 'n_patients': 100}};

const RMEAN_RANGE = {'min': {'model1': 0, 'model2': -6, 'model3': -5},
	             'max': {'model1': 8, 'model2': 1, 'model3': 1}};
const RSD_RANGE = {'min': {'model1': 0, 'model2': 0, 'model3': 0},
	           'max': {'model1': 20, 'model2': 20, 'model3': 20}};
const IMM_EFFECT_RANGE = {'min': {'model1': 1, 'model2': 1, 'model3': 1},
	                  'max': {'model1': 20, 'model2': 10000, 'model3': 20}};
const CHEMO_EFFECT_RANGE = {'min': {'model1': 0, 'model2': 0, 'model3': 0},
	                    'max': {'model1': 1, 'model2': 1, 'model3': 1}};
const PATIENT_RANGE = {'min': {'model1': 20, 'model2': 20, 'model3': 20},
	               'max': {'model1': 1000, 'model2': 1000, 'model3': 1000}};
