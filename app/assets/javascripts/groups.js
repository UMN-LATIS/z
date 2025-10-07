$(document).bind('turbolinks:load', function () {
  var userTable = $('#groups-table').DataTable({
     "language": {
       "emptyTable": I18n.t('views.groups.index.table.empty')
     },
     "pageLength": 25,
		 "autoWidth": false,
     "order": [3, "desc"],
     "columnDefs": [ {
      "targets": 4,
      "orderable": false
      } ],
     drawCallback: function(settings) {
       // Add aria-current to active pagination link for accessibility
       var pagination = $(this).closest('.dataTables_wrapper').find('.dataTables_paginate');
       pagination.find('.paginate_button').removeAttr('aria-current');
       pagination.find('.paginate_button.current').attr('aria-current', 'page');
     }
   });
});
