//= require jquery
//= require jquery_ujs

keywordDeleteFunction = function(element){
    var kwd = element.childNodes[0].textContent;
    var my_elem = $("#keyword-debug");
    //debugger  
    console.log("Delete ".concat(kwd));
    console.log("Element content ".concat($("#keyword-debug").html()));
    $("#keyword-debug").html('clicked '.concat(kwd));
    return false;
}

