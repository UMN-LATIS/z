$(document).bind('turbolinks:load', function () {
  var userTable = $('#groups-table').DataTable({
     "pageLength": 25,
		 "autoWidth": false,
     "order": [2, "desc"]
   });
});
