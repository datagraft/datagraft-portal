document.addEventListener('turbolinks:load', function() {
  var upwizardListOptions = {
    valueNames: [ 'sin-list-hidden-name', 'sin-list-hidden-user', 'sin-list-hidden-time' ]
  };

  var upwizardList = new List('upwizard-list', upwizardListOptions);

});

$(document).ready(function(){

    // This procedure will hide all occurences of class row-public
    // this is used for hiding all public elements in lists when loading a page.
    var className = '.row-public';
    var new_val = 'none';
    var x = document.querySelectorAll(className);
    var i;
    //debugger;
    for (i = 0; i < x.length; i++) {
      x[i].style.display = new_val;
    }
    console.log("hiding .row-public occurences " + i);

});

updateFilterPublicStyle = function(obj, className, blockStyle){
    var new_val = blockStyle;
    if (obj.checked == false) new_val = 'none';

    var x = document.querySelectorAll(className);
    //console.log("updateFilterPublic " + obj.checked + " " + x.length + " " +x[0].style.display);
    var i;
    //debugger;
    for (i = 0; i < x.length; i++) {
      x[i].style.display = new_val;
    }
}
