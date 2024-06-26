$(document).on("click", ".cancel-new-url", function(e) {
    e.preventDefault();
    $(this).closest("tr").remove();
});
$(document).on({
    ajaxStart: function () {
        $('body').css( 'cursor', 'progress' );
        $('a').css( 'cursor', 'progress' );
        $('button').css( 'cursor', 'progress' );
    },
    ajaxStop: function () {
        $('body').css( 'cursor', '' );
        $('a').css( 'cursor', '' );
        $('button').css( 'cursor', '' );
    }
});

$(document).on("submit", "form", function(e) {
    $(this).find(":submit").prop("disabled", true);
});

$(document).on("click", ".cancel-edit", function(e) {
    e.preventDefault();
    $('table.data-table').DataTable().draw();
});

$(document).on("change", "#urls-table select, body.urls.show select", function(e) {
    const select = e.target;
    var newVal = $(select).val();
    var urlId = $(select).data('url-id');
    if (!confirm(I18n.t("views.urls.move_confirm", {
            keyword: $(select).data('keyword'),
            collection: $(select).find(":selected").text()
        }))) {
        $(select).val($(select).data('group-id')); //set back
        return;
    }
    $.ajax({
        url: $(select).data('update-path'),
        method: 'PATCH',
        data: {
            url: {
                group_id: newVal
            }
        }
    });
});

$(document).bind('turbolinks:load', function() {
    // If going to the show page, load the google charts JS and
    // load the hrs24 chart
    $("[data-toggle='tooltip']").tooltip();

    if ($("body.urls.show").length > 0) {
        if (google.charts.Bar === undefined) {
            google.charts.load('current', {
                'packages': ['bar', 'geochart', 'corechart']
            });
        }
        google.charts.setOnLoadCallback(drawChartHrs24);
        google.charts.setOnLoadCallback(drawRegionsMap);
        google.charts.setOnLoadCallback(drawRegionsPie);

        //make sure the select picker on this page is initialized
        $(".selectpicker").selectpicker()
    }

});

// Load Javascript for the urls-index page
$(document).bind('turbolinks:load', function() {
    if ($("body.urls.index").length == 0) {
        return;
    }
    initializeUrlDataTable(6, "desc", 7, 4, $('.collection-count').data('collection-count') > 1, true);
});

// Turn the group select into the fancy select picker
$(document).on('show.bs.modal', function() {
    $("#index-modal select#Group").selectpicker();
});

// The rest of the charts need to be loaded upon showing the tab
// preloading the charts ruins their formatting
$(document).on('shown.bs.tab', function(e) {
    switch ($(e.target).data('load')) {
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

//these three should be one function.
function transferUrl(transferPath, keywords) {
    $.ajax({
        url: transferPath,
        data: {
            keywords: keywords
        },
        dataType: 'script'
    });
}
function batchDelete(batchDeletePath, keywords) {
    $.ajax({
        url: batchDeletePath,
        data: {
            keywords: keywords
        },
        dataType: 'script'
    });
}
function moveUrl(movePath, keywords) {
    $.ajax({
        url: movePath,
        data: {
            keywords: keywords
        },
        dataType: 'script'
    });
}

function changeGroup(groupPath, keyword) {
    $.ajax({
        url: groupPath,
        data: {
            keyword: keyword,
            modal: true
        },
        dataType: 'script'
    });
}

function initializeUrlDataTable(sortColumn, sortOrder, actionColumn, keywordColumn, showMoveButton, collectionSelect) {
    var transferText = '<i class="fa fa-exchange"></i> ' + I18n.t("views.urls.transfer_button");
    var moveText = '<i class="fa fa-share-square-o "></i> ' + I18n.t("views.urls.move_button");
    var batchDeleteText = '<i class="fa fa-trash-o "></i> ' + I18n.t("views.urls.batch_delete_button");
    var bulkActionsText = I18n.t("views.urls.bulk_actions") + '<i class="fa fa-sort-desc "></i> ';

    var $urlsTable = $('#urls-table');
    var userTable = $urlsTable.DataTable({
        drawCallback: function(settings) {
            var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
            pagination.toggle(this.api().page.info().pages > 1);
        },
        "pageLength": 25,
        "autoWidth": false,
        columns: [{
            defaultContent: "",
            className: 'select-checkbox',
            searchable: false,
            orderable: false,
            title: "<input type='checkbox' id='select-all' class='select-checkbox' aria-label='select/deselect all rows'/>"
        }, {
            data: 'group_id',
            visible: false,
            orderable: false
        }, {
            data: 'url',
            visible: false,
            orderable: false
        }, {
            data: 'keyword'
        }, {
            data: 'group_name'
        }, {
            data: 'total_clicks'
        }, {
            data: 'created_at'
        }, {
            data: 'actions',
            searchable: false,
            orderable: false
        }, ],
        "processing": true,
        "serverSide": true,
        "ajax": $('#urls-table').data('source'),
        "pagingType": "full_numbers",
        "order": [
            sortColumn,
            sortOrder
        ],
        select: {
            style: 'multi',
            selector: 'td:first-child'
        },
        initComplete: function() {
            if (collectionSelect) {
                selected_collection = $('.collection-selected').data('collectionSelected')
                this.api().columns([1]).every(function() {
                    var column = this;
                    var select = $('<select id="collection-filter" class="form-control" aria-label="Collections Filter"><option value="">' + I18n.t("views.urls.index.table.collection_filter.all") + '</option></select>')
                        .prependTo($("#urls-table_filter"))
                        .on('change', function() {
                            var val = $.fn.dataTable.util.escapeRegex(
                                $(this).val()
                            );
                            column
                                .search(val ? '^' + val + '$' : '', true, false)
                                .draw();
                        });
                    $('.collection-names').data('collection-names').forEach(function(d, j) {
                        select.append('<option value="' + d[0] + '">' + d[1] + '</option>')
                    });
                    select.before('<label for="collection-filter">' + I18n.t("views.urls.index.table.collection_filter.label") + ':</label>');
                    select.selectpicker();
                    if (selected_collection !== undefined) {
                        setTimeout(function() {
                            select.val(selected_collection).trigger("change");
                        }, 0);
                    }

                });
            }
        },
        fnDrawCallback: function() {
            enableDisableTableOptions();

						//for all the select pickers in the table
            $("table#urls-table .selectpicker").each(function(index, selectPicker) {

							$(selectPicker)
									//store current value
									.data("prev", selectPicker.value)

									//store current value if focused
									.on('focus', function(e) {
	                    $(e.currentTarget).data("prev", this.value); //store previous value
	                })

									//then add a new action at the bottom
									.append("<option class='bottom-action-option'>Create New Collection...</option")

									// and when changed
									.on("change", function(e) {
	                    var $target = $(e.currentTarget)
											//if the selected option was our new option
	                    if ($target.find("option.bottom-action-option:selected").length) {

	                        e.preventDefault();
	                        changeGroup($('.route-info').data('new-group-path'), $(e.currentTarget).data().keyword);
													$target.val($target.data("prev"));//restore its old value
	                        return false;
	                    }

											//else, update its old stored value.
	                    $target.data("prev", this.value);
	                });
            });

            $(".selectpicker").selectpicker();
            $(".selectpicker").attr("title", I18n.t("views.urls.index.table.collection_tooltip"))
            setTimeout(function() {
                $("#urls-table .selectpicker").tooltip();
            }, 300);
        }
    });

    $urlsTable.on('processing.dt', function(e, settings, processing) {
        if (processing) {
            $urlsTable.parent().prepend('<div class="loading-indicator-wrapper">' +
                '<div class="loading-indicator">' +
                '</div>' +
                '</div>');
        } else {
            $(".loading-indicator-wrapper").remove();
        }
    });

    //function for disabling bulk table options dropdown
    function enableDisableTableOptions(){
      var selectedRows = userTable.rows('.selected');
      if (selectedRows[0].length){
        $(".table-options").removeClass("disabled");
      }
      else{
        $(".table-options").addClass("disabled");

      }
    }

    //use the function for disabling bulk table options dropdown
    userTable.on('select', enableDisableTableOptions);
    userTable.on('deselect', enableDisableTableOptions);

    $('table.data-table').on("page.dt", function(e) {
        userTable.rows().deselect();
        $("#select-all").prop("checked", false);
    });
    $("#select-all").click(function(e) {
        $(e.target).prop("checked") === true ? userTable.rows({
            page: "current"
        }).select() : userTable.rows().deselect();
    });

    var transfer_button = {
        extend: 'selected',
        text: transferText,
        className: 'btn js-transfer-urls',
        action: function(e, dt, node, config) {
            var keywords = [];
            userTable.rows('.selected').data().map(function(row) {
                keywords.push(row['DT_RowData_keyword'])
            });
            transferUrl($('.route-info').data('new-transfer-request-path'), keywords);
        }
    }

    var move_button = {
        extend: 'selected',
        className: 'btn js-move-urls',
        text: moveText,
        action: function(e, dt, node, config) {
            var keywords = [];
            userTable.rows('.selected').data().map(function(row) {
                keywords.push(row['DT_RowData_keyword'])
            });

            moveUrl($('.route-info').data('new-move-to-group-path'), keywords);
        }
    }

    var batch_delete_button = {
        extend: 'selected',
        className: 'btn btn-danger js-delete-urls',
        text: batchDeleteText,
        action: function(e, dt, node, config) {
            var keywords = [];
            userTable.rows('.selected').data().map(function(row) {
                keywords.push(row['DT_RowData_keyword'])
            });

            batchDelete($('.route-info').data('new-batch-delete-path'), keywords);
        }
    }

    buttons = []
    if (showMoveButton) {
        buttons = [transfer_button, move_button, batch_delete_button]
    } else {
        buttons = [transfer_button]
    }

    var dropdown_button = {
        extend: 'collection',
        text: bulkActionsText,
        className: 'table-options',
        autoClose: true,
        fade: 200,
        buttons: buttons
    }

    new $.fn.dataTable.Buttons(userTable, {
        buttons: [dropdown_button]
    });

    userTable
        .buttons(0, null)
        .container()
        .prependTo('.dataTables_wrapper >.row:eq(0) > .col-sm-6:eq(0)');

    $(".col-sm-6 .dt-buttons").removeClass("btn-group");
    return userTable;
}

$(document).ready(function() {
    //url share actions
    $("[data-toggle='tooltip']").tooltip();
    $(document).on("click", ".share-url", function(e) {
        e.preventDefault();
    });
    $(document).on("click", ".js-share-button-twitter", function(e) {
        e.preventDefault();
        var shortUrl = $(this).data("shortUrl");
        window.open("https://twitter.com/intent/tweet?text=" + shortUrl, '', 'menubar=no, toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
    })
    $(document).on("click", ".url-blurb-close-button", function(e) {
        e.preventDefault();
        $(this).closest(".url-blurb")
            .addClass("off tw-overflow-hidden")
            .on("transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd", function() {
                $(this).remove();
            });
    });
});
