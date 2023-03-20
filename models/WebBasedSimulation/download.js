/** Convert a 2D array into a CSV string
 */
function survival_to_csv(death_times_treat, death_times_placebo){
	str = "Time,Treatment\n";
	treat_str = death_times_treat.map(value => [value, 1].join(',')).join('\n');
	placebo_str = death_times_placebo.map(value => [value, 0].join(',')).join('\n');
	return str + treat_str + "\n" + placebo_str;
}

function km_to_csv(d1, d2){
	str = "Time,Prop_alive,Treatment\n";
	treat_str = d1.map(value => [...value, 1].join(',')).join('\n');
	placebo_str = d2.map(value => [...value, 0].join(',')).join('\n');
	return str + treat_str + "\n" + placebo_str;
}

function downloadBlob(content, filename, contentType) {
  // Create a blob
  var blob = new Blob([content], { type: contentType });
  var url = URL.createObjectURL(blob);

  // Create a link to download it
  var pom = document.createElement('a');
  pom.href = url;
  pom.setAttribute('download', filename);
  pom.click();
}

