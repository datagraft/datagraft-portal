document.addEventListener('turbolinks:load', function() {
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
      scrollY: '57vh',
      "order": [],
  });

  oTable = $table.DataTable();
  $('#preview-search').keyup(function () {
    oTable.search($(this).val()).draw();
  });

});
