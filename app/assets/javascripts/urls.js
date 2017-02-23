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
  if ($("body.urls.show").length > 0) {
    if (google.charts.Bar === undefined) {
      google.charts.load('current', {'packages':['bar', 'geochart', 'corechart']});
    }
    google.charts.setOnLoadCallback(drawChartHrs24);
    google.charts.setOnLoadCallback(drawRegionsMap);
    google.charts.setOnLoadCallback(drawRegionsPie);
  }

});

// Load Javascript for the urls-index page
$(document).bind('turbolinks:load', function () {
  if ($("body.urls.index").length == 0) {
    return;
  }
  initializeUrlDataTable(4, "desc", 5, 2, $('.collection-count').data('collection-count') > 1);
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

function transferUrl(transferPath, keywords){
 $.ajax({
    url: transferPath,
    data: {keywords: keywords},
    dataType: 'script'
  });
}

function moveUrl(movePath, keywords){
  $.ajax({
    url: movePath,
    data: {keywords: keywords},
    dataType: 'script'
  });
}

function initializeUrlDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, showMoveButton) {
  var transferText = '<i class="fa fa-exchange"></i> Transfer to a different user';
  var moveText = '<i class="fa fa-share-square-o "></i> Move to a different collection';

  var userTable = $('#urls-table').DataTable({
     "pageLength": 25,

     columns: [
           {data: '0' },
           {data: '1' },
           {data: '2' },
           {data: '3' },
           {data: '4' },
           {data: '5' }
         ],
     "processing": true,
     "serverSide": true,
     "ajax": $('#urls-table').data('source'),
     "pagingType": "full_numbers",
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
           keywords.push(row['DT_RowData']['keyword'])
         });

         console.log("LOG:","trying to transfer");
         transferUrl($('.route-info').data('new-transfer-request-path'), keywords);

       }
     }

     var move_button = {
       extend: 'selected',
       className:'btn-primary js-move-urls',
       text: moveText,
       action: function ( e, dt, node, config ) {
         var keywords = [];
         userTable.rows('.selected').data().map(function (row) {
           keywords.push(row['DT_RowData']['keyword'])
         });

         moveUrl($('.route-info').data('new-move-to-group-path'), keywords);

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
       .buttons(0, null)
       .container()
       .prependTo('.dataTables_wrapper >.row:eq(0) > .col-sm-6:eq(0)');

     $(".col-sm-6 .dt-buttons").removeClass("btn-group");
}
