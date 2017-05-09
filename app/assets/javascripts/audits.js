// Load Javascript for the admin-index page
$(document).bind('turbolinks:load', function () {
    if ($("body.admin\\/audits.index").length == 0) {
        return;
    }
    initializeAuditDataTable(0, "asc");
});

function initializeAuditDataTable(sortColumn, sortOrder) {

    var userTable = $('#audits-table').DataTable({
        drawCallback: function(settings) {
            var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
            pagination.toggle(this.api().page.info().pages > 1);
        },
        "pageLength": 25,
        columns: [
            {data: 'item_type', searchable: false, orderable: false  },
            {data: 'event', searchable: false, orderable: false  },
            {data: 'whodunnit' },
            {data: 'audit_history', orderable: false  },
            {data: 'created_at', searchable: false, orderable: false  },
        ],
        "processing": true,
        "serverSide": true,
        "ajax": $('#audits-table').data('source'),
        "pagingType": "full_numbers",
        "order": [
            sortColumn,
            sortOrder
        ],
        select: {
            style:    'multi',
            selector: 'td:first-child'
        }
    });
 }

