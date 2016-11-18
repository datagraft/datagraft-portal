document.addEventListener('turbolinks:load', function() {
  var keywordListOptions = {
    valueNames: [ 'sin-list-keyword' , 'id'],
    item: '<li><span class="mdl-chip"><span class="mdl-chip__text sin-list-keyword"></span><button type="button" class="mdl-chip__action remove-keyword-btn"><i class="material-icons">cancel</i></button></span></li>'

  };

  var keywordList = new List('keyword-list', keywordListOptions);
  console.log("keywordList started len:"+keywordList.size());

  var addKeywordBtn = $('#add-keyword-btn'),
    formField = $('#filestore_keyword_list'),
    keywordField = $('#keyword-name-field'),
    idCntr = 0,
    removeBtns = $('.remove-keyword-btn');

  addKeywordsFromForm();
  // Sets callbacks to the buttons in the list
  refreshCallbacks('init');

  addKeywordBtn.click(function() {
    keywordList.add({
      'sin-list-keyword': keywordField.val(),
      'id': idCntr++
    });
    keywordField.val('');
    refreshCallbacks('add');
    writeKeywordsToForm();
  });

  function addKeywordsFromForm() {
    var txt = formField.val();
    if (!(txt === undefined)) {
      //console.log("Form keywords <" + txt + ">");
      var arr = txt.split(',');
      for (var i = 0; i < arr.length; i++) {
        var kwd = arr[i].trim();
        if (kwd.length > 0) {
          console.log("Form keyword "+i+" <" + kwd + ">");
          keywordList.add({
            'sin-list-keyword': kwd,
            'id': idCntr++
          });
        }
      }
    }
  }

  function writeKeywordsToForm() {
    var newTxt = "";
    var separator = "";
    for(var i = 0; i < idCntr; i++) {
      var entry = keywordList.get('id', i);
      if (entry.length == 1) {
        newTxt += separator;
        newTxt += entry[0].values()['sin-list-keyword'];
        separator = ", ";
      }
    }
    formField.val(newTxt);
    console.log("New keywords <" + newTxt + ">");
  }

  //function printItem(val) {
  //  console.log("List item <" + val + ">");
  //}

  function refreshCallbacks(txt) {
    // Needed to add new buttons to jQuery-extended object
    //console.log("<"+txt+"> keywordList refresh len:"+keywordList.size());
    //for(var i = 0; i < idCntr; i++) {
    //  var entry = keywordList.get('id', i);
    //  if (entry.length == 1) {
    //    printItem(entry[0].values()['sin-list-keyword']);
    //  }
    //}

    if (keywordList.size() > 0) keywordList.sort('sin-list-keyword', { order: "asc" });
    removeBtns = $(removeBtns.selector);

    removeBtns.click(function() {
      var itemId = $(this).closest('li').find('.sin-list-keyword').text();
      keywordList.remove('sin-list-keyword', itemId);
      writeKeywordsToForm();
    });
  }

});
