$(document).on("click", ".cancel-new-url", function (e) {
	e.preventDefault();
	$(this).closest("tr").remove();
});

$(document).bind('turbolinks:load', function () {
  Holder.run();

  // If going to the show page, load the google charts JS and
  // load the hrs24 chart
  if ($("body.urls.show")[0]){
    if (google.charts.Bar === undefined){
      google.charts.load('current', {'packages':['bar']});
    }
    google.charts.setOnLoadCallback(drawChartHrs24);
  }
});

// The rest of the charts need to be loaded upon showing the tab
// preloading the charts ruins their formatting
$(document).on('shown.bs.tab', function (e) {
  switch($(e.target).data('load')) {
    case 'hrs24':
        drawChartHrs24();
        break;
    case 'days7':
        drawChartDays7();
        break;
    case 'days30':
        drawChartDays30();
        break;
    case 'all':
        drawChartAllTime();
    default:
        break;
  }
})
