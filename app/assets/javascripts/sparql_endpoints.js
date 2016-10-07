document.addEventListener('turbolinks:load', function() {
  var queriesListOptions = {
    valueNames: [ 'name', 'city' ]
  };

  var queriesList = new List('queries-list', queriesListOptions);
  
  var seQueriesListOptions = {
    valueNames: [ 'sin-container-hidden-name', 'sin-container-hidden-date', 'sin-container-hidden-user' ]
  };

  var seQueriesList = new List('se-queries-list', seQueriesListOptions);

});
