$(document).on("click", ".cancel-new-url", function (e) {
	e.preventDefault();
	$(this).closest("tr").remove();
});

$(document).on("click", ".cancel-edit-url", function (e) {
	e.preventDefault();
	$('table.data-table').DataTable().draw();
});

$(document).on("change", "#urls-table select", function (e) {
  select = e.target;
	var newVal = $(select).val();
  var urlId = $(select).data('url-id');
  if (!confirm("Are you sure you wish to move short URL " + $(select).data('keyword') + " to collection " + $(select).find(":selected").text() + "?")) {
    $(select).val($(select).data('group-id')); //set back
        return;
  }
  $.ajax({
    url: $(select).data('update-path'),
    method: 'PATCH',
    data: {url: {group_id: newVal}}
  });
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
  initializeUrlDataTable(6, "desc", 7,4, $('.collection-count').data('collection-count') > 1, true);
});

// Load Javascript for the admin-index page
$(document).bind('turbolinks:load', function () {
  if ($("body.admin\\/urls.index").length == 0) {
    return;
  }
  initializeUrlDataTable(5, "desc", 6, 3, false, false);
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

function initializeUrlDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, showMoveButton, collectionSelect) {
  var transferText = '<i class="fa fa-exchange"></i> Transfer to a different user';
  var moveText = '<i class="fa fa-share-square-o "></i> Move to a different collection';

  var userTable = $('#urls-table').DataTable({
          drawCallback: function(settings) {
              var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
              pagination.toggle(this.api().page.info().pages > 1);
          },
     "pageLength": 25,
     columns: [
          {
            defaultContent: "",
            className: 'select-checkbox',
            searchable: false,
            orderable: false,
            title:"<input type='checkbox' id='select-all' class='select-checkbox'/>"
          },
          {data: 'group_id', visible: false, orderable: false},
          {data: 'group_name' },
          {data: 'url' },
          {data: 'keyword' },
          {data: 'total_clicks' },
          {data: 'created_at' },
          {data: 'actions', searchable: false, orderable: false },
         ],
     "processing": true,
     "serverSide": true,
     "ajax": $('#urls-table').data('source'),
     "pagingType": "full_numbers",
     "order": [
       sortColumn,
       sortOrder
     ],
     select: {
       style:    'multi',
       selector: 'td:first-child'
     },
     initComplete: function () {
        if(collectionSelect) {
         this.api().columns([1]).every( function () {
             var column = this;
             var select = $('<select id="collection-filter" class="form-control"><option value="">All</option></select>')
                 .prependTo( $("#urls-table_filter") )
                 .on( 'change', function () {
                     var val = $.fn.dataTable.util.escapeRegex(
                         $(this).val()
                     );
                     column
                         .search( val ? val : '')
                         .draw();
                 } );

             $('.collection-names').data('collection-names').forEach( function ( d, j ) {
                 select.append( '<option value="'+d[0]+'">'+d[1]+'</option>' )
             } );
             select.before('<label>Collection:</label>');
         } );
       }
     }

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
         transferUrl($('.route-info').data('new-transfer-request-path'), keywords);
       }
     }

     var move_button = {
       extend: 'selected',
       className: 'btn-primary js-move-urls',
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

     userTable
       .buttons(0, null)
       .container()
       .prependTo('.dataTables_wrapper >.row:eq(0) > .col-sm-6:eq(0)');

     $(".col-sm-6 .dt-buttons").removeClass("btn-group");
}

//url share actions
$(document).ready(function(){
	$("body").on("click", ".url-share-button-twitter",function(e){
		e.preventDefault();
		var shortUrl = $(this).data("shortUrl");
		window.open("https://twitter.com/intent/tweet?text=" + shortUrl, '', 'menubar=no, toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	})
	$("body").on("click", ".url-share-button-facebook",function(e){
		e.preventDefault();
		var shortUrl = $(this).data("shortUrl");
		// window.open("https://twitter.com/intent/tweet?text=" + shortUrl, '', 'menubar=no, toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	})
	$("body").on("click", ".url-share-button-qr", function(e){
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
	$(".share-url").popover({html:true, trigger:"click", placement:"top"})
		.click(function(e){
			e.preventDefault();
		});
});
