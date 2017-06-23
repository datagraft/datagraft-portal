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
    event.stopPropagation();
  });

  $('.sin-execute-request-button form').on("ajax:success", function(e, data, status, xhr) {
    $('#query-panel-result').html(data);
    $('#query-panel-result').show();
    createResultsTable();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#query-panel-result').html(xhr.responseText);
  });

  // ==================================
  //          Query list code
  // ==================================

  var genListOptions = {
    valueNames: [ 'sin-gl-hidden-name', 'sin-gl-hidden-user', 'sin-gl-hidden-date', 'sin-gl-hidden-linked-to-endpoint' ],
    listClass: 'sin-gl-list'
  };

  var genList = new List('sparql-gen-list', genListOptions);
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
  updateGlAssociatedStyle();
});


var updateGlAssociatedStyle = function(){
  var include_public_queries = !$('#gen_checkbox_public')[0].checked;
  var display_only_linked_queries = $('#gen_checkbox_associated')[0].checked;
  
  var allRows = $('.sin-gl-list > li');
  
  allRows.each(function (index, row) {
    var is_linked_subelement = $(row).find('.sin-gl-hidden-linked-to-endpoint')[0],
        is_linked_query_row = $(is_linked_subelement).text() === "true",
        is_public_row = $(row).hasClass('sin-gl-row-public');
    // we hide the row if a query is NOT linked and the filter 'display only linked queries' is checked OR if the query is public (other user) and the 'include public queries' option is NOT checked
    if ((display_only_linked_queries && !is_linked_query_row) || (is_public_row && !include_public_queries)) {
      row.style.display = 'none';
    } else {
      row.style.display = 'block';
    }
  });
}
