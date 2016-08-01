document.addEventListener('turbolinks:load', function() {

  // Generates empty rows for the DataTables so it displays better when less items are present in a page
  function generateEmptyRows(tableObj, targetRows) {

    var tableRows = tableObj.find('tbody tr'); // the existing data rows
    var numberNeeded = targetRows - tableRows.length; // # blank rows needed to fill up to targetRows
    var lastRow = tableRows.last(); // last data row
    var lastRowCells = lastRow.children('td'); //visible columns
    var cellString;
    var rowClassCurr;
    // the empty rows that are added to the table
    var emptyRows;
    // Check to see the class of the row (may be relevant for CSS)
    if (targetRows % 2) {
      rowClassCurr = "odd";
    } else {
      rowClassCurr = "even"; //
    }

    // Generate and add HTML code for the rows that are added
    for (i=0; i < numberNeeded; ++i){
      cellString = '<tr/>';
      lastRow.after(cellString);
    }

    emptyRows = tableObj.find('tr.empty-row');
    emptyRows.each(function(index, emptyRow) {
    });

  }
  // Manually upgrades all tooltip div elements to material design elements. Necessary for DataTables dynamic elements when using pagination.
  function upgradeTooltipsMDL(tableObj) {
    var tooltipElements = tableObj.find('tbody tr td div.mdl-tooltip');
    tooltipElements.each(function(index, tooltip) {
      componentHandler.upgradeElement(tooltip);
    });

  }

  // Initialise DataTables table
  var $table = $('#dashboard-user-assets-table');
  $table.dataTable({
    responsive: true,
    pagingType: 'full_numbers',
    dom: 'lfrti<"mdl-card__actions mdl-card--border"p>',
    scroller: true,
    scrollCollapse: true,
    scrollY: "70vh",
    "drawCallback": function(oSettings) {
      var numcolumns = this.oApi._fnVisbleColumns(oSettings);
      generateEmptyRows($table, 10);
      upgradeTooltipsMDL($table);
    },
    "columnDefs": [
      { "width": "5%", "targets": 0 },
      { "width": "35%", "targets": 1 },
      { "width": "15%", "targets": 2 },
      { "width": "15%", "targets": 3 },
      { "width": "15%", "targets": 4 },
      { "width": "10%", "targets": 5 }
    ]
  });


});