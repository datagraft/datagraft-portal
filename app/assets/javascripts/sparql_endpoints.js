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

  var createResultsTable = function () {
    var oTable,
        $table;
    $table = $('#query-results-table');

    $table.dataTable({
      'lengthMenu': [[10, 25, 50, -1], [10, 25, 50, 'All']],
      responsive: true,
      dom: 'lrti<"mdl-card__actions mdl-card--border"p>',
      scroller: true,
      scrollCollapse: true,
      scrollY: '70vh',
      pagingType: 'full_numbers',
      drawCallback: function (oSettings) {
        $(".dataTables_scrollHeadInner").css({"width":"100%"});
        $(".mdl-data-table").css({"width":"100%"});
        $("#query-results-table_wrapper").css({"width":"90%"});
      },
    });
    oTable = $('#query-results-table').DataTable();
    console.log($('.mdl-textfield'))
    $('.mdl-textfield').each(function (index, element) {
      componentHandler.upgradeElement(element);  
    });

    $('#query-results-search').keyup(function () {
      oTable.search($(this).val()).draw();
    });
  };

  $('#query-panel form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
    $('#query-panel-result').show();
    createResultsTable();
    $('#se-queries-list').hide();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  $('.sin-execute-request-button').click(function(event) {
    // execute form but do not unfold 
    $(this).children().first().submit();
    event.stopPropagation();
  });

  $('.sin-execute-request-button form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
    $('#query-panel-result').show();
    createResultsTable();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  var seQueriesListOptions = {
    valueNames: [ 'sin-container-hidden-name', 'sin-container-hidden-date', 'sin-container-hidden-user' ]
  };

  var seQueriesList = new List('se-queries-list', seQueriesListOptions);
  $('.row-public').each(function () {
    !$('#checkbox_public')[0].checked ? $(this).css("display", 'none') : $(this).css("display", '');
  });
});
