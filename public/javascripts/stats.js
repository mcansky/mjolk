$(document).ready(function() {
		$.getJSON('/stats/stats.json', function(stats) {
			var options = {xaxis: {
			    mode: "time",
			    timeformat: "%d/%m/%y"
			  }};
			
			$.plot($("#stats_users"), [{label: "users", data: stats[0], color: "#6E92FF",lines: { show: true }}],
				options);

			$.plot($("#stats_bookmarks"), [
				{label: "bookmarks", data: stats[1], color: "#E86A4D",lines: { show: true, }}],
				options);
				
			$.plot($("#stats_tags"), [{label: "tags", data: stats[2], color: "#81E79D", lines: { show: true }}],
				options);
		});
});