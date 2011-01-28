$(document).ready(function() {
		$.getJSON('/stats/stats.json', function(stats) {
			var options = {xaxis: {
			    mode: "time",
			    timeformat: "%d/%m/%y"
			  }};
			
			$.plot($("#placeholder"), [{label: "users", data: stats[0],lines: { show: true }},
				{label: "bookmarks", data: stats[1],lines: { show: true, }},
				{label: "tags", data: stats[2], lines: { show: true }}],
				options);
		});
});