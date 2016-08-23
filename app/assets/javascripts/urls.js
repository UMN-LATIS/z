$(document).on("click", ".cancel-new-url", function (e) {
	e.preventDefault();
	$(this).closest("tr").remove();
});

$(document).on("click", ".cancel-edit-url", function (e) {
	e.preventDefault();
	$('table.data-table').DataTable().draw();
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

function initializeUrlDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, transferPath, movePath, showMoveButton) {
  var transferText = 'Transfer to user';
  var moveText = 'Move to group';
  var selectAllText = 'Select all';
  var selectNoneText = 'Select none'

  var userTable = $('table.data-table').DataTable({
    "pageLength": 25,
    buttons: [
      {
        text: selectAllText,
        action: function ( e, dt, node, config ) {
          dt.rows({page: 'current'}).select();
        }
      },
      'selectNone'
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
        targets:   0
      },{
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

  userTable
    .buttons()
    .container()
    .appendTo('.dataTables_wrapper .col-sm-6:eq(0)');

  var transfer_button = {
    extend: 'selected',
    text: transferText,
    action: function ( e, dt, node, config ) {
      var keywords = [];
      userTable.rows('.selected').data().map(function (row) {
        keywords.push(row[keywordColumn])
      });

      $.ajax({
        url: transferPath,
        data: {keywords: keywords},
        dataType: 'script'
      });
    }
  }

  var move_button = {
    extend: 'selected',
    text: moveText,
    action: function ( e, dt, node, config ) {
      var keywords = [];
      userTable.rows('.selected').data().map(function (row) {
        keywords.push(row[keywordColumn])
      });

      $.ajax({
        url: movePath,
        data: {keywords: keywords},
        dataType: 'script'
      });
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

  userTable
    .buttons(1, null)
    .container()
    .appendTo('.dataTables_wrapper .col-sm-6:eq(0)');
}
