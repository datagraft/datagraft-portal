document.addEventListener('turbolinks:load', function() {

  var setEndpointURL = function () {
    $.ajax({
      url: window.location.pathname + '/url.json',
      type: 'GET',
      timeout: 5000,
      error: function (xhr, textStatus, thrownError) {
        if(textStatus === "timeout") {
          console.log("Server took too long to respond when asking for URL!");
          console.log(xhr.status);
          console.log(thrownError);
          $('#sparql-loading-error-container > .sin-error-message').text('Server took too long to respond! Try refreshing this page...');
          $('#sparql-endpoint-address').hide();
          $('#sparql-loading-error-container').show();
          $('#tooltip-clipboard').hide();
          $('.sin-loading-bar-container').hide();
        } else {
          console.log("Error fetching SPARQL endpoint URL!");
          console.log(xhr.status);
          console.log(thrownError);
          $('#sparql-loading-error-container > .sin-error-message').text('Error fetching URL for endpoint! Try refreshing this page...');
          $('#sparql-endpoint-address').hide();
          $('#sparql-loading-error-container').show();
          $('#tooltip-clipboard').hide();
          $('.sin-loading-bar-container').hide();
        }
        return false;
      },
      success: function (res) {
        if (res.url) {
          $('#sparql-endpoint-address > a').text(res.url);
          $('#sparql-endpoint-address').show();
          $('#tooltip-clipboard').show();
          $('#tooltip-clipboard').attr('data-clipboard-text', res.url);
          $('.sin-loading-bar-container').hide();
          $('#surveyor-iframe').attr('src', '/RDFsurveyor/index.html?repo=' + res.proxy);
        } else {
          // could not get URL?? Should not happen but just in case
          console.log('URL not found! Please try again later;');
          $('#sparql-loading-error-container > .sin-error-message').text('Error fetching URL for endpoint! Try refreshing this page...');
          $('#sparql-endpoint-address').hide();
          $('#sparql-loading-error-container').show();
          $('#tooltip-clipboard').hide();
          $('.sin-loading-bar-container').hide();
        }
      }
    })
  }

  var pollEndpointTransient = async function() {
    // after four seconds - reload the page
    setTimeout(() => {
      window.location.reload(1);
    }, 4000);
  }

  var pollEndpointState = async function() {
    var endpointState = $('#endpoint-state').text();
    // repository not yet created
    if(endpointState !== 'repo_created') {
      // hide the address field and show the loading bar
      $('#sparql-endpoint-address').hide();
      $('#sparql-loading-error-container').hide();
      $('#tooltip-clipboard').hide();
      $('.sin-loading-bar-container').show();

      // after four seconds - issue a request for the state of the endpoint
      setTimeout(() => {
        $.ajax({
          url: window.location.pathname + '/state.json',
          type: 'GET',
          timeout: 5000,
          error: function (xhr, textStatus, thrownError) {
            if(textStatus === "timeout") {
              console.log("Server took too long to respond when asking for URL!");
              console.log(xhr.status);
              console.log(thrownError);
              $('#sparql-loading-error-container > .sin-error-message').text('Server took too long to respond! Try refreshing this page...');
              $('#sparql-endpoint-address').hide();
              $('#sparql-loading-error-container').show();
              $('#tooltip-clipboard').hide();
              $('.sin-loading-bar-container').hide();
            } else {
              console.log("Error polling server for SPARQL endpoint state!");
              console.log(xhr.status);
              console.log(thrownError);
              $('#sparql-loading-error-container > .sin-error-message').text('Error fetching endpoint state! Try refreshing this page...');
              $('#sparql-endpoint-address').hide();
              $('#sparql-loading-error-container').show();
              $('#tooltip-clipboard').hide();
              $('.sin-loading-bar-container').hide();
            }
          },
          success: function (res) {
            // null safety first
            if (res.state) {
              $('#endpoint-state').text(res.state);
              if (res.state === 'repo_created') {
                // SPARQL endpoint successfully created - we can now get the URL
                $('#sparql-loading-bar-label').text('Success! Getting URL of endpoint...');
                setTimeout(() => {
                  setEndpointURL();
                }, 2000)
              } else if (res.state === 'error_creating_repo') {
                // Something went wrong creating the repository
                $('#sparql-endpoint-address').hide();
                $('#sparql-loading-error-container').show();
                $('#tooltip-clipboard').hide();
                $('.sin-loading-bar-container').hide();
              } else if (res.state === 'creating_repo') {
                // Repo still not created and no error has occured - time to try again
                console.log("Repo still not created - time to try again");
                pollEndpointState();
              } else {
                // Repo state inconsistent...maybe it will change? Should not happen, but maybe we would like to do something in the future?
                console.log("Repo still not created - state inconsistent");
                pollEndpointState();
              }
            } else {
              // Response is empty or null? Something went wrong!
              console.log("Error getting state of the SPARQL endpoint! Please try again later.");
            }
          }
        })
      }, 4000);
    }
  }

  if($('#endpoint-state').length) {
    pollEndpointState();
  }
  if($('#endpoint-transient').length) {
    pollEndpointTransient();
  }



  if($('#sparql-loading-error-container').length) {
    $('#sparql-loading-error-container').hide();
  }
  updateGlAssociatedStyle = function(){
    if ($('#gen_checkbox_public')[0])
      var include_public_queries = !$('#gen_checkbox_public')[0].checked;
    if ($('#gen_checkbox_associated')[0])
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

  $('.sin-gen-squeeze-sparql').squeezebox({
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

var updateGlAssociatedStyle = function(){}
