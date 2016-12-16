document.addEventListener('turbolinks:load', function() {
  var genListOptions = {
    valueNames: [ 'sin-gl-hidden-name', 'sin-gl-hidden-user', 'sin-gl-hidden-date' ],
    listClass: 'sin-gl-list'
  };

  var genList = new List('gen-list', genListOptions);
  // Avoid error message when sorting empty list
  if (genList.size() > 0) genList.sort('sin-gl-hidden-date', { order: "desc" });

  $('.sin-gen-squeeze').squeezebox({
    headers: '.sin-gs-head',
    folders: '.sin-gs-cnt',
    closeOthers: false,
    closedOnStart: true,
    animated : true
  });

  $('.sin-gl-stop-propagate').click(function(event) {
    // execute form but do not unfold squeezebox
    event.stopPropagation();
  });

  // This procedure will hide all occurences of class row-public
  // this is used for hiding all public elements in lists when loading a page.
  var className = '.sin-gl-row-public';
  var new_val = 'none';
  var x = document.querySelectorAll(className);
  var i;
  //debugger;
  for (i = 0; i < x.length; i++) {
    x[i].style.display = new_val;
  }
  console.log("hiding .sin-gl-row-public occurences tb " + i);

});



//$(document).ready(function(){
//
//  // This procedure will hide all occurences of class row-public
//  // this is used for hiding all public elements in lists when loading a page.
//  var className = '.sin-gl-row-public';
//  var new_val = 'none';
//  var x = document.querySelectorAll(className);
//  var i;
//  //debugger;
//  for (i = 0; i < x.length; i++) {
//    x[i].style.display = new_val;
//  }
//  console.log("hiding .sin-gl-row-public occurences " + i);
//
//});

var updateGlPublicStyle = function(obj, blockStyle){
  var className = '.sin-gl-row-public';
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
