$(document).bind('turbolinks:load', function () {
  var userTable = $('#members-table').DataTable({
     "pageLength": 25,
		 "autoWidth": false,
     "order": [0, "asc"],
     searching: false,
     "columnDefs": [ {
      "targets": 2,
      "orderable": false
      } ]
   });
});
