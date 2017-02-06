//clipboard button logic
$(document).bind('turbolinks:load', function(){

  var clipboard = new Clipboard(".clipboard-btn");
  $(".clipboard-btn").tooltip({
    trigger: 'click'
  });

  function setTooltip(btn, message) {
      $(btn).tooltip('hide');

      setTimeout(function(){
        $(btn)
          .attr('data-original-title', message)
          .tooltip('show');
      }, 200);
  }

  function hideTooltip(btn) {
    setTimeout(function() {
      $(btn).tooltip('hide');
    }, 1000);
  }

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
    hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
    hideTooltip(e.trigger);
  });
});
