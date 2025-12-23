/**
 * Accessibility fix for data-confirm-modal gem
 *
 * This is a patch for accessibility issues with the
 * `data-confirm-modal` gem. The gem creates Bootstrap modals
 *  for confirmation dialogs which lack aria-describedby pointing
 *  to modal body. This means screen readers only announce the
 *  title ("Are you sure?") but not the actual confirmation
 *  message text.
 *
 * To patch, when a modal is shown, we detect if it's a
 * data-confirm-modal (with a hacky check for
 * the `.commit` button class used by the gem), then add:
 *  - an ID to the modal-body element
 *  - aria-describedby attr pointing to the modal body
 *  @see GH issue #230
 *
 * A more robust fix would prob be to move to the native
 * `<dialog>` element, but that would require additional
 * styling and could be a more substantial change.
 */

$(document).on("show.bs.modal", '.modal[role="dialog"]', function (e) {
  const modal = $(e.target);

  // Only apply to data-confirm modals
  // The .commit class is specific to data-confirm-modal gem's "Confirm" button
  if (modal.find(".modal-body").length && modal.find(".commit").length) {
    const modalId = modal.attr("id");
    const bodyId = `${modalId}-body`;

    // Add ID to modal body if it doesn't have one
    const modalBody = modal.find(".modal-body");
    if (!modalBody.attr("id")) {
      modalBody.attr("id", bodyId);
    }

    // Add aria-describedby to modal to reference the body
    const existingDescribedBy = modal.attr("aria-describedby");
    if (!existingDescribedBy || !existingDescribedBy.includes(bodyId)) {
      modal.attr("aria-describedby", bodyId);
    }
  }
});
