// set the dimensions and margins of the graph

var margin = {top: 50, right: 5, bottom: 120, left: 100},
    width = 775 - margin.left - margin.right,
    height = 520 - margin.top - margin.bottom;


var current_model = document.getElementById("model").value
set_model_defaults(current_model);
// var R_mu = document.getElementById('R_mu').value
// var R_sigma = document.getElementById('R_sigma').value
// var raise_killing = document.getElementById('raise_killing').value
// var chemo_effect = document.getElementById('chemo_effect').value
// var n_patients = document.getElementById('n_patients').value
simulation_fn = get_simulation_fn(current_model)

var svg = d3.select("#my_dataviz")
  	    .append("svg")
    	    .attr("width", width + margin.left + margin.right)
    	    .attr("height", height + margin.top + margin.bottom)
  	    .append("g")
    	    .attr("transform",
          	"translate(" + margin.left + "," + margin.top + ")");

  // add the x Axis
  const x_ax = d3.scaleLinear()
            .domain([0, MAX_X_VALUE])
            .range([0, width]);

  svg.append("g")
      .attr("transform", "translate(0," + height + ")")
      .attr("class", "axis")
      .call(d3.axisBottom(x_ax).tickValues([0, 3, 6, 9, 12, 15, 18, 21, 24]));

  svg.append("text")
	.attr("transform",
	      "translate(" + (width/2) + " ," + (height + margin.top - 10) + ")")
	.style("text-anchor", "middle")
	.attr("class", "axislabels")
	.text("Time (Months)")
	.attr("font-weight", 600);

  // add the y Axis
  const y_ax = d3.scaleLinear()
            .range([height, 0])
            .domain([0, 1.0]);
  svg.append("g")
      .attr("class", "axis")
      .call(d3.axisLeft(y_ax));
  
  svg.append("text")
	.attr("transform", "rotate(-90)")
	.attr("class", "axislabels")
	.attr("y", 0 - margin.left + 40)
	.attr("x", 0 - (height/2))
	.attr("dy", "1em")
	.style("text-anchor", "middle")
	.text("Proportion Alive")
	.attr("font-weight", 600);

// Add legend
svg.append('g')
   .append('path')
	.datum([[21.5, 0.89], [22.5, 0.89]])
	.attr("fill", "none")
	.attr("stroke", "black")
	.attr("stroke-width", 2)
	.style("opacity", 0.7)
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);
svg.append('text')
        .attr("x", 610)
	.attr("y", 45)
	.text("Placebo");

svg.append('g')
   .append('path')
	.datum([[21.5, 0.80], [22.5, 0.80]])
	.attr("fill", "none")
	.attr("stroke", "red")
	.attr("stroke-width", 2)
	.style("opacity", 0.7)
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);

svg.append('text')
        .attr("x", 610)
	.attr("y", 75)
	.text("Treatment");

// Text for no at risk
svg.append('text')
	.attr("x", x_ax(0) - 100)
	.attr("y", height + margin.top + 20)
	.attr("class", "noatrisk")
	.text("No. at risk:")
svg.append('text')
	.attr("x", x_ax(0) - 100)
	.attr("y", height + margin.top + 40)
	.text("Treatment");
svg.append('text')
	.attr("x", x_ax(0) - 100)
	.attr("y", height + margin.top + 60)
	.text("Placebo");

function plot(data_placebo, data_treat, no_at_risk, median_survival, data_progress) {
  // Delete the previous lines
  svg.selectAll('.mypath, .mypath_prog, .mypath_dashed').remove();

  // Plot the median lines
  var median_treatment = svg
	.append('g')
	.append('path')
	.attr('class', 'mypath_dashed')
	.datum([[0, 0.5], [median_survival['treatment'], 0.5]])
	.attr("fill", "none")
	.attr("stroke", "red")
	.attr("stroke-width", 1)
	.style("opacity", 0.6)
	.transition()
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);
  svg.append('g')
	.append('path')
	.attr('class', 'mypath_dashed')
	.datum([[median_survival['treatment'], 0.5], [median_survival['treatment'], 0]])
	.attr("fill", "none")
	.attr("stroke", "red")
	.attr("stroke-width", 1)
	.style("opacity", 0.6)
	.transition()
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);
  
  var median_placebo = svg
	.append('g')
	.append('path')
	.attr('class', 'mypath_dashed')
	.datum([[0, 0.5], [median_survival['placebo'], 0.5]])
	.attr("fill", "none")
	.attr("stroke", "black")
	.attr("stroke-width", 1)
	.style("opacity", 0.6)
	.transition()
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);
  svg.append('g')
	.append('path')
	.attr('class', 'mypath_dashed')
	.datum([[median_survival['placebo'], 0.5], [median_survival['placebo'], 0]])
	.attr("fill", "none")
	.attr("stroke", "black")
	.attr("stroke-width", 1)
	.style("opacity", 0.6)
	.transition()
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);

  // Plot the survival curve
  if (data_placebo != null){
  	var placebo = svg
  	  .append('g')
  	  .append("path")
  	    .attr("class", "mypath")
  	    .datum(data_placebo)
  	    .attr("fill", "none")
  	    .attr("stroke", "black")
  	    .attr("stroke-width", 2)
	    .style("opacity", 0.7)
	    .transition()
  	    .attr("d",  d3.line()
  	        .x(function(d) { return x_ax(d[0]); })
  	        .y(function(d) { return y_ax(d[1]); })
  	    );
  }

  if (data_treat != null){
  	var treat = svg
  	  .append('g')
  	  .append("path")
  	    .attr("class", "mypath")
  	    .datum(data_treat)
  	    .attr("fill", "none")
  	    .attr("stroke", "red")
  	    .attr("stroke-width", 2)
	    .style("opacity", 0.7)
	    .transition()
  	    .attr("d",  d3.line()
  	        .x(function(d) { return x_ax(d[0]); })
  	        .y(function(d) { return y_ax(d[1]); })
  	    );
  }

  // Plot the progress bar
  var progress = svg
	.append('g')
	.append('path')
	.attr('class', 'mypath_prog')
	.datum(data_progress)
	.attr("fill", "none")
	.attr("stroke", "grey")
	.attr("stroke-width", 8)
	.style("opacity", 0.6)
	.transition()
	.attr("d", d3.line()
		.x(function(d) { return x_ax(d[0]); })
		.y(function(d) { return y_ax(d[1]); })
	);

  svg.append('text')
	.attr('class', 'mypath_prog')
	.attr("transform",
	      "translate(" + (width/2) + " ," + -25 + ")")
	.style("text-anchor", "middle")
	.text(Math.round((data_progress[1][0] / MAX_X_VALUE)*100) + "%")

  // Plot the no at risk numbers
  no_at_risk_positions = NO_AT_RISK_TIMEPOINTS.map((e, i) => x_ax(e));
  for (i=0; i<no_at_risk_positions.length; i++){
	  svg.append('text')
	  	.attr('class', 'no_at_risk_text')
	  	.attr("transform",
			"translate(" + no_at_risk_positions[i] + " ," + (height + margin.top + 40) + " )")
	  	.style("text-anchor", "middle")
	  	.text(no_at_risk['treatment'][i])
  }
  for (i=0; i<no_at_risk_positions.length; i++){
	  svg.append('text')
	  	.attr('class', 'no_at_risk_text')
	  	.attr("transform",
			"translate(" + no_at_risk_positions[i] + " ," + (height + margin.top + 60) + " )")
	  	.style("text-anchor", "middle")
	  	.text(no_at_risk['placebo'][i])
  }
};

d3.select("#R_mu").on("change", function(d){
	R_mu = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})
d3.select("#R_mu_value").on("change", function(d){
	R_mu = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})

d3.select("#R_sigma").on("change", function(d){
	R_sigma = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})
d3.select("#R_sigma_value").on("change", function(d){
	R_sigma = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})


d3.select("#raise_killing").on("change", function(d){
	raise_killing = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})
d3.select("#imm_effect_value").on("change", function(d){
	raise_killing = this.value;
	if (raise_killing < 1){
		raise_killing = 1;
		document.getElementById('raise_killing').value = 1;
		document.getElementById('imm_effect_value').value = 1;
	}
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})


d3.select("#chemo_effect").on("change", function(d){
	chemo_effect = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})
d3.select("#chemo_effect_value").on("change", function(d){
	chemo_effect = this.value;
	if (chemo_effect > 1){
		chemo_effect = 1;
		document.getElementById('chemo_effect').value = 1;
		document.getElementById('chemo_effect_value').value = 1;
	}
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})

d3.select("#n_patients").on("change", function(d){
	n_patients = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})
d3.select("#n_patients_value").on("change", function(d){
	n_patients = this.value;
	cancel_sim(timeout_ids);
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})

d3.select("#model").on("change", function(d){
	current_model = this.value
	simulation_fn = get_simulation_fn(current_model);
	cancel_sim(timeout_ids);
	set_model_defaults(current_model);

	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients);
})

function cancel_sim(timeout_ids){
	for (i=0; i < timeout_ids.length; i++){
		clearTimeout(timeout_ids[i]);
	}
}

function plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n){
	console.log("Running simulation for model: " + current_model + ", R mean: " + R_mu + ", R sigma: " + R_sigma + ", Immuno effect: " + raise_killing + ", chemo effect: " + chemo_effect + ", patients: " + n);
	let death_times_treat = [];
	let death_times_placebo = [];
	let fun_calls = [];
	
	function get_next_patient(){
		svg.selectAll('.no_at_risk_text').remove();
		let no_at_risk = {"placebo":[], "treatment": []};

		// Get the survival values
		let d_treat = simulation_fn( R_mu, R_sigma, raise_killing, chemo_effect, 1 );
		death_times_treat.push( parseFloat(d_treat[0]) );
	

		let d_placebo = simulation_fn(R_mu, R_sigma, 1, 1, 1);
		death_times_placebo.push( parseFloat(d_placebo[0]) );
	
		// Compute the no at risk values for placebo and treatment arm
		for (let i=0; i<NO_AT_RISK_TIMEPOINTS.length; i++){
			no_at_risk['treatment'].push(array_sum(vectorCompareEqual(death_times_treat, NO_AT_RISK_TIMEPOINTS[i])));
		}

		for (let i=0; i<NO_AT_RISK_TIMEPOINTS.length; i++){
			no_at_risk['placebo'].push(array_sum(vectorCompareEqual(death_times_placebo, NO_AT_RISK_TIMEPOINTS[i])));
		}

		// Compute mean survivals
		document.getElementById('mean_survival_placebo').innerHTML = mean(death_times_placebo, 25);
		document.getElementById('mean_survival_treatment').innerHTML = mean(death_times_treat, 25);

		// Compute survival proportions
		death_times_treat = death_times_treat.sort((a,b) => a - b);
		d1 = [[0,1]];
		for( let i = 0 ; i < death_times_treat.length ; i ++ ){
			if (death_times_treat[i] < MAX_X_VALUE){
				d1.push( [death_times_treat[i],1-(i+1)/death_times_treat.length] );
			}
		}
		d1.push([MAX_X_VALUE, array_sum(death_times_treat.map(i => i > MAX_X_VALUE? 1: 0))/death_times_treat.length]);
		
		death_times_placebo = death_times_placebo.sort((a,b) => a - b);
		d2 = [[0,1]];
		for( let i = 0 ; i < death_times_placebo.length ; i ++ ){
			if (death_times_placebo[i] < MAX_X_VALUE){
				d2.push( [death_times_placebo[i],1-(i+1)/death_times_placebo.length] );
			}
		}
		d2.push([MAX_X_VALUE, array_sum(death_times_placebo.map(i => i > MAX_X_VALUE? 1: 0))/death_times_placebo.length]);
		
		// Compute median survivals
		median_survival = {'placebo': median(death_times_placebo), 'treatment': median(death_times_treat)};

		data_progress = [[0, 1.05], [((n_patients-n)/n_patients)*MAX_X_VALUE, 1.05]]
		plot(d2, d1, no_at_risk, median_survival, data_progress);
		if( --n > 0 ){
			fun_calls.push(setTimeout( get_next_patient, 0 ));
		} else {
			svg.selectAll('.mypath_prog').remove();
		}
	}
	get_next_patient();

	return [death_times_treat, death_times_placebo, fun_calls];
}

function rerun_sim(){
	[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients)
}

[death_times_treat, death_times_placebo, timeout_ids] = plot_pop(simulation_fn, R_mu, R_sigma, raise_killing, chemo_effect, n_patients)
