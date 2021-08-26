$(document).bind("turbolinks:load", function() {
  var userTable = $("#members-table").DataTable({
    pageLength: 25,
    autoWidth: false,
    order: [0, "asc"],
    searching: false,
    columnDefs: [
      {
        targets: 2,
        orderable: false,
      },
    ],
  });
});

// new member form submit button disabled unless
// all required fields have some value
$(() => {
  const newMemberForm = document.querySelector("form.new_member");
  if (!newMemberForm) return;

  function handleNewMemberFormChange() {
    const requiredInputs = document.querySelectorAll(
      ".new_member input[required]"
    );

    const submitButton = document.querySelector(
      '.new_member button[type="submit"]'
    );

    const hasValue = (input) => !!input.value.length;
    const isComplete = (inputEls) => [...inputEls].every(hasValue);

    submitButton.disabled = !isComplete(requiredInputs);
  }

  ["keyup", "change", "paste"].forEach((eventType) =>
    newMemberForm.addEventListener(eventType, handleNewMemberFormChange)
  );

  // init submit button on page load
  handleNewMemberFormChange();
});
