document.addEventListener('turbolinks:load', function() {

  // Display query execute result
  //$('.sin-execute-request-button form').on("ajax:success", function(e, data, status, xhr) {
  $('#query-show-execute-form form').on("ajax:success", function(e, data, status, xhr) {
    console.log("Success");
    $('#query-show-execute-result').html(data);
    $('#query-show-execute-result').show();
  }).on("ajax:error", function(e, xhr, status, error) {
    console.log("Error");
    $('#query-show-execute-result').html(xhr.responseText);
  });
  
});
