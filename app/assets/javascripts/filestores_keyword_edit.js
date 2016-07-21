//= require jquery
//= require jquery_ujs

keywordDeleteFunction = function(element){
    var kwd = element.childNodes[0].textContent;
    var my_elem = $("#keyword-debug");
    var form_keyw = $("#filestore_keywords");
    var arr_keyw = JSON.parse(form_keyw.html());
    var new_arr_keyw = [];
    console.log("Form content ".concat(form_keyw.html()));
    var j = 0;
    for(i=0; i<arr_keyw.length; i++) {
      if(arr_keyw[i] != kwd) {
        new_arr_keyw[j++] = arr_keyw[i];
      }
    }
    console.log("Form content ".concat(form_keyw.html()));
    //debugger  
    console.log("Delete ".concat(kwd));
    console.log("Debug content ".concat(my_elem.html()));
    console.log("Form content ".concat(form_keyw.html()));
    my_elem.html(JSON.stringify(new_arr_keyw));
    return false;
}

  