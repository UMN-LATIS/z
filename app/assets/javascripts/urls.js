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
                'packages': ['geochart', 'corechart']
            });
        }
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
    var $urlsTable = $('#urls-table');
    var userTable = $urlsTable.DataTable({
        drawCallback: function(settings) {
            var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
            pagination.toggle(this.api().page.info().pages > 1);

            // Add aria-current to active pagination link for accessibility
            pagination.find('.paginate_button').removeAttr('aria-current');
            pagination.find('.paginate_button.current').attr('aria-current', 'page');
        },
        "pageLength": 25,
        "autoWidth": false,
        columns: [{
            defaultContent: "<input type='checkbox' class='select-checkbox' aria-label='Select row'/>",
            className: 'select-checkbox__container',
            searchable: false,
            orderable: false,
            title: "<input type='checkbox' id='select-all' class='select-checkbox' aria-label='Select all rows'/>"
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
                    var select = $(`
                        <select id="collection-filter"
                            class="collection-filter-select">
                            <option value="">
                                ${I18n.t("views.urls.index.table.collection_filter.all")}
                            </option>
                        </select>
                    `)
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

    //function for disabling bulk action buttons when no rows are selected
    function enableDisableTableOptions(){
      const selectedRows = userTable.rows('.selected');
      const isDisabled = selectedRows[0].length === 0;
      $(".js-transfer-urls, .js-move-urls, .js-delete-urls").attr("aria-disabled", isDisabled.toString());
    }

    //use the function for disabling bulk action buttons
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

    // Create bulk action buttons container
    const $bulkActionsContainer = $('<div class="bulk-actions-buttons"></div>');

    // Transfer button
    const $transferButton = $(`
        <button type="button"
                class="btn btn-default js-transfer-urls bulk-action-btn"
                aria-disabled="true"
                data-toggle="tooltip"
                title="${I18n.t("views.urls.transfer_button")}">
            <span class="sr-only">${I18n.t("views.urls.transfer_button")}</span>
            <i class="fa fa-exchange" aria-hidden="true"></i>
        </button>
    `);
    $transferButton.on('click', (e) => {
        if ($(e.currentTarget).attr('aria-disabled') === 'true') {
            e.preventDefault();
            return false;
        }
        const keywords = userTable.rows('.selected').data().map(row => row['DT_RowData_keyword']).toArray();
        transferUrl($('.route-info').data('new-transfer-request-path'), keywords);
    });
    $bulkActionsContainer.append($transferButton);

    const $moveButton = $(`
        <button type="button"
                class="btn btn-default js-move-urls bulk-action-btn"
                aria-disabled="true"
                data-toggle="tooltip"
                title="${I18n.t("views.urls.move_button")}">
            <span class="sr-only">${I18n.t("views.urls.move_button")}</span>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><!-- Icon from Material Symbols by Google - https://github.com/google/material-design-icons/blob/master/LICENSE --><path fill="currentColor" d="M8 18q-.825 0-1.412-.587T6 16v-1q0-.425.288-.712T7 14t.713.288T8 15v1h12V6H8v1q0 .425-.288.713T7 8t-.712-.288T6 7V4q0-.825.588-1.412T8 2h12q.825 0 1.413.588T22 4v12q0 .825-.587 1.413T20 18zm-4 4q-.825 0-1.412-.587T2 20V7q0-.425.288-.712T3 6t.713.288T4 7v13h13q.425 0 .713.288T18 21t-.288.713T17 22zm9.175-10H7q-.425 0-.712-.288T6 11t.288-.712T7 10h6.175l-.9-.9Q12 8.825 12 8.413t.3-.713q.275-.275.7-.275t.7.275l2.6 2.6q.3.3.3.7t-.3.7l-2.6 2.6q-.275.275-.687.288T12.3 14.3q-.275-.275-.275-.7t.275-.7z"/></svg>
        </button>
    `);
    $moveButton.on('click', (e) => {
        if ($(e.currentTarget).attr('aria-disabled') === 'true') {
            e.preventDefault();
            return false;
        }
        const keywords = userTable.rows('.selected').data().map(row => row['DT_RowData_keyword']).toArray();
        moveUrl($('.route-info').data('new-move-to-group-path'), keywords);
    });
    $bulkActionsContainer.append($moveButton);

    // Batch delete button (always shown)
    const $deleteButton = $(`
        <button type="button"
                class="btn btn-outline-danger js-delete-urls bulk-action-btn"
                aria-disabled="true"
                data-toggle="tooltip"
                title="${I18n.t("views.urls.batch_delete_button")}">
            <span class="sr-only">${I18n.t("views.urls.batch_delete_button")}</span>
            <i class="fa fa-trash-o" aria-hidden="true"></i>
        </button>
    `);
    $deleteButton.on('click', (e) => {
        if ($(e.currentTarget).attr('aria-disabled') === 'true') {
            e.preventDefault();
            return false;
        }
        const keywords = userTable.rows('.selected').data().map(row => row['DT_RowData_keyword']).toArray();
        batchDelete($('.route-info').data('new-batch-delete-path'), keywords);
    });
    $bulkActionsContainer.append($deleteButton);

    // Add buttons to the DataTable wrapper
    $bulkActionsContainer.prependTo('.dataTables_wrapper >.row:eq(0) > .col-sm-6:eq(0)');

    // Initialize tooltips
    $('.bulk-action-btn').tooltip();

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
