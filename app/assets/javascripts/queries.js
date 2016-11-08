document.addEventListener('turbolinks:load', function() {

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
  
  // Display query execute result
  $('#query-show-execute-form form').on("ajax:success", function(e, data, status, xhr) {
    console.log("Success");
    $('#query-show-execute-result').html(data);
    $('#query-show-execute-result').show();
    createResultsTable();
  }).on("ajax:error", function(e, xhr, status, error) {
    console.log("Error");
    $('#query-show-execute-result').html(xhr.responseText);
  });
  
  
});
