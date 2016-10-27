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
    $(this).hide();
  });

  $('#close-query-panel').click(function() {
    $('#open-query-panel').show();
    $(this).hide();
    $('#query-panel').hide();
  });

  $('#query-panel form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  $('.sin-execute-request-button').on("ajax:success", function(e, data, status, xhr) {
    $(this).parents('.container').find('.sin-execute-request-response').html(data);
  }).on("ajax:error", function(e, xhr, status, error) {
    $(this).parents('.container').find('.sin-execute-request-response').html(xhr.responseText);
  });

  var queriesListOptions = {
    valueNames: [ 'name', 'city' ]
  };

  var queriesList = new List('queries-list', queriesListOptions);

  var seQueriesListOptions = {
    valueNames: [ 'sin-container-hidden-name', 'sin-container-hidden-date', 'sin-container-hidden-user' ]
  };

  var seQueriesList = new List('se-queries-list', seQueriesListOptions);

});
