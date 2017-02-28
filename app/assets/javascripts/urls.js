$(document).on("click", ".cancel-new-url", function (e) {
	e.preventDefault();
	$(this).closest("tr").remove();
});

$(document).on("click", ".cancel-edit-url", function (e) {
	e.preventDefault();
	$('table.data-table').DataTable().draw();
});

$(document).bind('turbolinks:load', function () {

  // If going to the show page, load the google charts JS and
  // load the hrs24 chart
  if ($("body.urls.show")[0]){
    if (google.charts.Bar === undefined){
      google.charts.load('current', {'packages':['bar', 'geochart', 'corechart']});
    }
    google.charts.setOnLoadCallback(drawChartHrs24);
    google.charts.setOnLoadCallback(drawRegionsMap);
    google.charts.setOnLoadCallback(drawRegionsPie);
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

function initializeUrlDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, transferPath, movePath, showMoveButton) {
  var transferText = '<i class="fa fa-exchange"></i> Transfer to a different user';
  var moveText = '<i class="fa fa-share-square-o "></i> Move to a different collection';
  var selectAllText = 'Select all';
  var selectNoneText = 'Select none'

  var userTable = $('table.data-table').DataTable({
      drawCallback: function(settings) {
          var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
          pagination.toggle(this.api().page.info().pages > 1);
      },
      "pageLength": 25,
    buttons: [

    ],
    language: {
      buttons: {
        selectAll: selectAllText,
        selectNone: selectNoneText
      }
    },
    "order": [
      sortColumn,
      sortOrder
    ],
    columnDefs: [
      {
        className: 'select-checkbox',
        targets:   0,
				title:"<input type='checkbox' id='select-all' class='select-checkbox'/>"
      },
			{
        orderable: false,
        searchable: false,
        targets: [0, actionColumn]
      }
    ],
    select: {
      style:    'multi',
      selector: 'td:first-child'
    },
  });

	$('table.data-table').on("page.dt", function(e){
			userTable.rows().deselect();
			$("#select-all").prop("checked", false);
	});

	$("#select-all").click(function(e){
			$(e.target).prop("checked") === true ? userTable.rows({page:"current"}).select() : userTable.rows().deselect();
	});

  var transfer_button = {
    extend: 'selected',
    text: transferText,
			className:'btn-primary js-transfer-urls',
    action: function ( e, dt, node, config ) {
      var keywords = [];
      userTable.rows('.selected').data().map(function (row) {
        keywords.push(row[keywordColumn]['@data-search'])
      });

			transferUrl(transferPath, keywords);

    }
  }

  var move_button = {
    extend: 'selected',
		className:'btn-primary js-move-urls',
    text: moveText,
    action: function ( e, dt, node, config ) {
      var keywords = [];
      userTable.rows('.selected').data().map(function (row) {
        keywords.push(row[keywordColumn]['@data-search'])
      });

    	moveUrl(movePath, keywords);

    }
  }

  buttons = []
  if (showMoveButton) {
    buttons = [transfer_button, move_button]
  } else {
    buttons = [transfer_button]
  }

  new $.fn.dataTable.Buttons( userTable, {
    buttons: buttons
  });

	window.userTable = userTable;
  userTable
    .buttons(1, null)
    .container()
		.prependTo('.dataTables_wrapper >.row:eq(0) > .col-sm-6:eq(0)');

	$(".col-sm-6 .dt-buttons").removeClass("btn-group");
}

//url blurb actions
$(document).bind('turbolinks:load', function(){
	$("body").on("click", ".url-blurb-action-button-twitter",function(e){
		e.preventDefault();
		var shortUrl = $(this).data("shortUrl");
		window.open("https://twitter.com/intent/tweet?text=" + shortUrl, '', 'menubar=no, toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	})
	$("body").on("click", ".url-blurb-action-button-facebook",function(e){
		e.preventDefault();
		var shortUrl = $(this).data("shortUrl");
		// window.open("https://twitter.com/intent/tweet?text=" + shortUrl, '', 'menubar=no, toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	})
	$("body").on("click", ".url-blurb-action-button-qr", function(e){
		e.preventDefault();
		window.open($(this).data("path"))

	});
	$("body").on("click", ".url-blurb-close-button", function(e){
		e.preventDefault();
		$(this).closest(".url-blurb")
		.addClass("off")
		.on("transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd", function(){
			$(this).remove();
		})
	});
});
