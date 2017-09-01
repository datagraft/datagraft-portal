document.addEventListener('turbolinks:load', function () {
  var oTable,
      $table;
  // configure DataTables to perform search using filter values
  $.fn.dataTable.ext.search.push(function( settings, data, dataIndex ) {
    if (settings.nTable.getAttribute('id')!=="dashboard-user-assets-table") {
//      ignore other tables
       return true;
    }
    var getFiles = $('#dashboard-filter--files').is(':checked'),
        getSparql = $('#dashboard-filter--sparql').is(':checked'),
        getTransformations = $('#dashboard-filter--transformations').is(':checked'),
        getQueries = $('#dashboard-filter--queries').is(':checked'),
        assetTypeStr = data[0],
        owner = data[2],
        filterPublicAssets = !$('#dashboard-filter--public').is(':checked') && !(owner === 'You');

    //    var shouldFilterPublicAssets = filterPublicAssets && !(owner ==='You');

    return !filterPublicAssets && (assetTypeStr == 'Filestore' && getFiles || assetTypeStr == 'Data Page' && getFiles || assetTypeStr == 'Query' && getQueries || assetTypeStr == 'Sparql Endpoint' && getSparql || assetTypeStr == 'Transformation' && getTransformations);
  });

  // Calculates how to display the asset menu element (on the top or bottom) to avoid scrolling in the assets table
  function calculateMenuClass (menuButtonId) {
    var tableOffset = $('#dashboard-user-assets-table').offset().top,
        menuButtonOffset = $('#' + menuButtonId).offset().top,
        buttonHeight = $('#' + menuButtonId).height(),
        tableHeight = $('#dashboard-user-assets-table').height(),
        menuHeight = $('[for=' + menuButtonId + ']').height();

    if ((menuButtonOffset - tableOffset) + menuHeight + buttonHeight > tableHeight) {
      $('[for=' + menuButtonId + ']').removeClass('mdl-menu--bottom-right').addClass('mdl-menu--top-right');
    } else {
      $('[for=' + menuButtonId + ']').removeClass('mdl-menu--top-right').addClass('mdl-menu--bottom-right');
    }
  }

  // Generates empty rows for the DataTables so it displays better when less items are present in a page
  function generateEmptyRows(tableObj, targetRows) {
    var tableRows = tableObj.find('tbody tr'), // the existing data rows
        numberNeeded = targetRows - tableRows.length, // # blank rows needed to fill up to targetRows
        lastRow = tableRows.last(), // last data row
        cellString,
        emptyRows, // the empty rows that are added to the table
        i;

    // Generate and add HTML code for the rows that are added
    for (i = 0; i < numberNeeded; ++i) {
      cellString = '<tr/>';
      lastRow.after(cellString);
    }

    emptyRows = tableObj.find('tr.empty-row');
    emptyRows.each(function (index, emptyRow) {
    });

  }

  // Manually upgrade elements to material design elements. Necessary for DataTables dynamic elements when using pagination.
  function upgradeTooltipsAndSwitchesMDL(tableObj) {
    var tooltipElements = tableObj.find('tbody tr td div.mdl-tooltip'),
        switchElements = tableObj.find('tbody tr td label.mdl-switch'),
        buttonElements = tableObj.find('tbody tr td button.mdl-button'),
        menuElements = tableObj.find('tbody tr td ul.mdl-menu');

    tooltipElements.each(function (index, tooltip) {
      componentHandler.upgradeElement(tooltip);
    });

    switchElements.each(function (index, switchElement) {
      componentHandler.upgradeElement(switchElement);
    });

    buttonElements.each(function (index, buttonElement) {
      calculateMenuClass($(buttonElement).attr('id'));
      componentHandler.upgradeElement(buttonElement);
    });

    menuElements.each(function (index, menuElement) {
      componentHandler.upgradeElement(menuElement);
    });

  }

  // attach callback for click events on current page
  $('.dashboard-user-assets__is-public-cell :checkbox').click(function (event) {
    var $this = $(this),
        hrefUpdateParam = !$this.is(':checked'),
        id = $this.attr('id'),
        currentHref,
        new_asset_state;

    new_asset_state = !hrefUpdateParam ? 'public' : 'private';
    if ( confirm('Are you sure you want to make this asset ' + new_asset_state +'?') ) {
      // get the ID of the toggle
      id = id.split('switch-')[1];
      // get the HREF attribute of the link for toggling public/private
      currentHref = $('#toggle-public-' + id).attr('href');
      // trigger the change of public/private
      $('#toggle-public-' + id).click();
      // update the HREF link to toggle the 'public' attribute
      $('#toggle-public-' + id).attr('href', currentHref.split('&public=')[0] + '&public=' + hrefUpdateParam);
    } else {
      event.preventDefault();
    }
  });

  // Initialise DataTables table
  $table = $('#dashboard-user-assets-table');
  $table.dataTable({
    'lengthMenu': [[10, 25, 50, -1], [10, 25, 50, 'All']],
    responsive: true,
    pagingType: 'full_numbers',
    dom: 'lrti<"mdl-card__actions mdl-card--border"p>',
    scroller: true,
    scrollCollapse: true,
    scrollY: '57vh',
    drawCallback: function (oSettings) {
      upgradeTooltipsAndSwitchesMDL($table);
      var numcolumns = this.oApi._fnVisbleColumns(oSettings);
      generateEmptyRows($table, 10);
      $(".dataTables_scrollHeadInner").css({"width":"100%"});
      $(".mdl-data-table").css({"width":"100%"});
    },
    'columnDefs': [
      
      { orderData: [6], targets: [4] },
      { orderData: [7], targets: [3] },
      { 'width': '10%', 'targets': 0 },
      { 'width': '35%', 'targets': 1 },
      { 'width': '15%', searchable: true, 'targets': 2 },
      { 'width': '15%', searchable: false, 'targets': 3 },
      { 'width': '15%', searchable: false, 'targets': 4 },
      { 'width': '10%', searchable: false, 'targets': 5 },
      { visible: false, searchable: false, 'targets': 6 },
      { visible: false, searchable: false, 'targets': 7 },
    ]
  });

  // Custom search box
  oTable = $('#dashboard-user-assets-table').DataTable();
  $('#dashboard-assets-search').keyup(function () {
    oTable.search($(this).val()).draw();
  });

  // Filter assets based on owner
  $('#dashboard-filter--public').click(function () {
    var $this = $(this),
        isChecked = $this.is(':checked');
    oTable.search($('#dashboard-assets-search').val()).draw();
  });

  // Filter assets based on asset type (using checkboxes)
  $('.sin-dashboard-asset-filters :checkbox').click(function () {
    var $this = $(this),
        isChecked = $this.is(':checked'),
        id = $this.attr('id');

    // resolve the checkboxes state
    switch (id) {
      case 'dashboard-filter--all':
        if(isChecked) {
          // if we just checked the 'All' checkbox - check all other checkboxes too
          $('.mdl-js-checkbox').has('#dashboard-filter--files')[0].MaterialCheckbox.check();
          $('.mdl-js-checkbox').has('#dashboard-filter--sparql')[0].MaterialCheckbox.check();
          $('.mdl-js-checkbox').has('#dashboard-filter--transformations')[0].MaterialCheckbox.check();
          $('.mdl-js-checkbox').has('#dashboard-filter--queries')[0].MaterialCheckbox.check();
        } else {
          // otherwise - un-check all other checkboxes
          $('.mdl-js-checkbox').has('#dashboard-filter--files')[0].MaterialCheckbox.uncheck();
          $('.mdl-js-checkbox').has('#dashboard-filter--sparql')[0].MaterialCheckbox.uncheck();
          $('.mdl-js-checkbox').has('#dashboard-filter--transformations')[0].MaterialCheckbox.uncheck();
          $('.mdl-js-checkbox').has('#dashboard-filter--queries')[0].MaterialCheckbox.uncheck();
        }
        break;
      default:
        if(!isChecked) {
          // we uncheck 'All' if another option has been unchecked
          $('.mdl-js-checkbox').has('#dashboard-filter--all')[0].MaterialCheckbox.uncheck();
        }
        break;
    }

    // re-draw table content
    oTable.search($('#dashboard-assets-search').val()).draw();
  });

  // re-draw table when the window is resized
  $(window).resize(function() {
    $('#dashboard-user-assets-table').DataTable().draw();
  });

});