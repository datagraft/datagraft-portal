// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require cocoon
//= require material
//= require jquery.gridster.js
//= require dataTables/jquery.dataTables

document.addEventListener('turbolinks:load', function() {
  componentHandler.upgradeDom();

  window.setTimeout(function() {
    $('.alert.alert-notice').hide();
  }, 4200);

  $('body').on('cocoon:after-insert', function(e, insert) {
    componentHandler.upgradeDom();
    console.log("jaach")
  });

// TODO change to something more meaningful
  window.supercanard = $(".gridster ul").gridster({
      widget_margins: [10, 10],
      widget_base_dimensions: [140, 140]
  });
});