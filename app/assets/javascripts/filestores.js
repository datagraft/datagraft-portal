document.addEventListener('turbolinks:load', function() {
  $('#filestore-preview-table').DataTable({
      paging: false,
      pagingType: 'full_numbers',
      "order": [],
  });
});
