$(document).on("click", ".move-transfer-request-url", function (e) {
  e.preventDefault();
  if ($(this).closest('tbody').attr('id') == "transfer-request-available-urls") {
    $(this).closest('tr').appendTo("#transfer-request-selected-urls");
  } else {
    $(this).closest('tr').appendTo("#transfer-request-available-urls");
  }
});
