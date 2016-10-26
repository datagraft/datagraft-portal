document.addEventListener('turbolinks:load', function() {
  var upwizardListOptions = {
    valueNames: [ 'sin-list-hidden-name', 'sin-list-hidden-user', 'sin-list-hidden-time' ]
  };

  var upwizardList = new List('upwizard-list', upwizardListOptions);

});

updateFilterPublic = function(obj, className){
    var new_val = "inline";
    if (obj.checked == false) new_val = 'none';

    var x = document.querySelectorAll(className);
    //console.log("updateFilterPublic " + obj.checked + " " + x.length + " " +x[0].style.display);
    var i;
    //debugger;
    for (i = 0; i < x.length; i++) {
      x[i].style.display = new_val;
    }
}
