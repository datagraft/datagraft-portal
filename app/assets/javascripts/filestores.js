document.addEventListener('turbolinks:load', function() {

  var createPreviewTable = function () {
    var oTable,
        $table;
    $table = $('#filestore-preview-table');

    $table.DataTable({
      'lengthMenu': [[10, 25, 50, -1], [10, 25, 50, 'All']],
      responsive: true,
      "searching": true,
      pagingType: 'full_numbers',
      dom: 'lrti<"mdl-card__actions mdl-card--border"p>',
      scroller: true,
      scrollCollapse: true,
      "scrollX": true,
      "order": []
    });

    oTable = $table.DataTable();
    $('#preview-search').keyup(function () {
      oTable.search($(this).val()).draw();
    });
  };
  createPreviewTable();

  $('.sin-ajax-preview-button').click(function(event) {
    // execute form but do not unfold
    $(this).children().first().submit();
    event.stopPropagation();
  });

  $('.sin-ajax-preview-button form').on("ajax:success", function(e, data, status, xhr) {
    $('#preview-panel-result').html(data);
    $('#preview-panel-result').show();
    createPreviewTable();
  }).on("ajax:error", function(e, xhr, status, error) {
    $('#preview-panel-result').html(xhr.responseText);
  });
  
  // re-draw table when the window is resized
  $(window).resize(function() {
    $('#filestore-preview-table').DataTable().draw();
  });
  
});
