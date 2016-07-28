document.addEventListener('turbolinks:load', function() {
  
  // generates empty rows for the DataTables 
  function fcmcAddRows(obj, targetRows) {

    var tableRows = obj.find('tbody tr'); // the existing data rows
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
//      cellString = '<tr role="row" class="empty-row ' + rowClassCurr + '"' + '>';
//      rowClassCurr === "odd" ? rowClassCurr = "even" : rowClassCurr = "odd";
//      lastRowCells.each(function() {
//        cellString += '\n' + '<td/>';
//      });
//      cellString += '\n' + "</tr>";
      lastRow.after(cellString);
    }
    
    emptyRows = obj.find('tr.empty-row');
    emptyRows.each(function(index, emptyRow) {
//      emptyRow.style.height = lastRow.height() + 'px';
//      console.log(lastRow.height());
//      console.log(emptyRow);
    });

  }

  //  var paginationOptions = {
  //    name: "pagination-dashboard-assets-table",
  //    paginationClass: "pagination-dashboard-assets-table",
  //    innerWindow: 3,
  //    left: 5,
  //    right: 2
  //  };
  //  
  //  var fuzzySearchOptions = {
  //    
  //  };
  //  
  //  var options = {
  //    valueNames: [ 'dashboard-user-assets__name-cell' ],
  //    page: 5,
  //    plugins: 
  //    [ ListFuzzySearch(),
  //     ListPagination(paginationOptions)
  //    ],
  //    listClass: 'dashboard-asset-table-body'
  //  };
  //
  //  var userList = new List('dashboard-user-assets', options);
  var $table = $('#dashboard-user-assets-table');
  $table.dataTable({
    responsive: true,
    pagingType: 'full_numbers',
    "dom": 'lrti<"mdl-card__actions mdl-card--border"p>',
    scroller: true,
    scrollCollapse: true,
    scrollY: "70vh",
    "drawCallback": function(oSettings) {
      var numcolumns = this.oApi._fnVisbleColumns(oSettings);
      console.log(numcolumns);
      fcmcAddRows($table, 10);
    }
  });


  //  var dataTableOptions = {
  //    responsive: true,
  //    pagingType: "full_numbers",
  //    "sScrollY": "0px",
  //    "fnDrawCallback": function() {
  //      var $dataTable = $table.dataTable();
  //      $dataTable.fnAdjustColumnSizing(false);
  //
  //      // TableTools
  //      if (typeof(TableTools) != "undefined") {
  //        var tableTools = TableTools.fnGetInstance(table);
  //        if (tableTools != null && tableTools.fnResizeRequired()) {
  //          tableTools.fnResizeButtons();
  //        }
  //      }
  //      //
  //      var $dataTableWrapper = $table.closest(".dataTables_wrapper");
  //      var panelHeight = $dataTableWrapper.parent().height();
  //
  //      var toolbarHeights = 0;
  //      $dataTableWrapper.find(".fg-toolbar").each(function(i, obj) {
  //        toolbarHeights = toolbarHeights + $(obj).height();
  //      });
  //
  //      var scrollHeadHeight = $dataTableWrapper.find(".dataTables_scrollHead").height();
  //      var height = panelHeight - toolbarHeights - scrollHeadHeight;
  //      $dataTableWrapper.find(".dataTables_scrollBody").height(height - 24);
  //
  //      $dataTable._fnScrollDraw();
  //    }
  //  };
  //
  //  $('#dashboard-user-assets-table').DataTable({
  //    dataTableOptions
  //  });
});