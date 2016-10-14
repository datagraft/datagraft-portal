document.addEventListener('turbolinks:load', function() {
  var upwizardListOptions = {
    valueNames: [ 'sin-list-name', 'sin-list-user', 'sin-list-time' ]
  };

  var upwizardList = new List('upwizard-list', upwizardListOptions);

});
