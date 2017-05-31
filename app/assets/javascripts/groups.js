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
      } ]
   });
});
