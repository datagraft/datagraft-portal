document.addEventListener('turbolinks:load', function() {
  var jGridster = $(".gridster ul");
  if (!jGridster.length) return;

  var jLayoutMetadata = $('#datapage-layout-metadata');

  jGridster.gridster({
      max_cols: 3,
      extra_rows: 1,
      widget_margins: [10, 10],
      widget_base_dimensions: [140, 140],
      helper: 'clone',
      resize: {
        enabled: true
      }
  });

  var gridsterInstance = jGridster.data('gridster');

  var previousSerialization = jLayoutMetadata.val();
  if (previousSerialization) {
    console.log(previousSerialization);
    try {
      $.each(JSON.parse(previousSerialization), function() {
        gridsterInstance.add_widget('<li></li>', this.size_x, this.size_y, this.col, this.row);
      });
    } catch(e) {
      if (window.console) console.log(e);
    }
  }

  var nbWidgets = $('.sin-form-widget').length;
  var nbGridster = jGridster.children().length;

  // Creating the remaining widgets if necessary
  for (;nbGridster < nbWidgets; ++nbGridster) {
    gridsterInstance.add_widget('<li></li>');
  }

  // Removing the widgets if necessary
  for (;nbWidgets > nbWidgets; --nbGridster) {
    var widget = jGridster.children(':last');
    gridsterInstance.remove_widget(widget); 
  }

  // Adding widgets
  $('body').on('cocoon:after-insert', function(e, insertedItem) {
    gridsterInstance.add_widget('<li></li>');

  // Removing the widgets
  }).on('cocoon:before-remove', function(e, removedItem) {
    // Try to get the same correct index
    var index = removedItem.index('.sin-form-widget');
    var widget = jGridster.children().eq(index - 1);
    gridsterInstance.remove_widget(widget); 
  });

  if (!jLayoutMetadata.length) return;

  // Saving the serialization of the layout
  jLayoutMetadata.parents('form').submit(function() {
    try {
      jLayoutMetadata.val(JSON.stringify(gridsterInstance.serialize()));
    } catch(e) {}
  });
});
