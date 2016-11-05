document.addEventListener('turbolinks:load', function() {

  $('.accordion').squeezebox({
      headers: '.squeezhead',
      folders: '.squeezecnt',
      closeOthers: false,
      closedOnStart: true,
      animated : true
  });

  $('#open-query-panel').click(function() {
    $('#query-panel, #close-query-panel').show();
    $('#se-queries-list').hide();
    $(this).hide();
  });

  $('#close-query-panel').click(function() {
    $('#open-query-panel').show();
    $(this).hide();
    $('#query-panel').hide();
    $('#se-queries-list').show();
    $('#query-panel-result').hide();
  });

  $('#query-panel form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
    $('#query-panel-result').show();
    $('#se-queries-list').hide();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  $('.sin-execute-request-button form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
    $('#query-panel-result').show();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  var seQueriesListOptions = {
    valueNames: [ 'sin-container-hidden-name', 'sin-container-hidden-date', 'sin-container-hidden-user' ]
  };

  var seQueriesList = new List('se-queries-list', seQueriesListOptions);

});
