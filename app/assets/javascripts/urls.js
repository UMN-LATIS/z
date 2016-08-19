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

function initializeUrlDataTable(sort_column, sort_order, action_column, keyword_column, transfer_path) {
  var user_table = $('table.data-table').DataTable({
    "pageLength": 25,
    buttons: [
         {
            text: 'Select all',
            action: function ( e, dt, node, config ) {
                dt.rows({page: 'current'}).select();
            }
        },
         'selectNone'
     ],
   language: {
       buttons: {
           selectAll: "Select all",
           selectNone: "Select none"
       }
   },
    "order": [ sort_column, sort_order ],
    columnDefs: [ {
            className: 'select-checkbox',
            targets:   0
        },
        {
            orderable: false,
            searchable: false,
            targets: [0, action_column]
    }],
    select: {
            style:    'multi',
            selector: 'td:first-child'
    },
  });

  user_table.buttons().container()
        .appendTo( '.dataTables_wrapper .col-sm-6:eq(0)' );

  new $.fn.dataTable.Buttons( user_table, {
        buttons: [
          {
             extend: 'selected',
             text: 'Transfer to user',
             action: function ( e, dt, node, config ) {
               var table = $('table.data-table').DataTable();
               var keywords = [];

               table.rows('.selected').data().map(function (row) {
                 keywords.push(row[keyword_column])
               });

               $.ajax({
                 url: transfer_path,
                 data: {keywords: keywords},
                 dataType: 'script'
               });
             }
         },
         {
            extend: 'selected',
            text: 'Move to group',
            action: function ( e, dt, node, config ) {
              $("#index-modal .modal-body").html("Move")
                $("#index-modal").modal()
            }
        }
        ]
    } );

    user_table.buttons(1, null).container()
          .appendTo( '.dataTables_wrapper .col-sm-6:eq(0)' );
}