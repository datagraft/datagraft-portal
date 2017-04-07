
document.addEventListener('turbolinks:load', function() {

  // Screenshots carousel
  var screenshotsContainer = document.getElementById("screenshots-container");

  if (screenshotsContainer) {
      screenshotsContainer.addEventListener("click", function() {
          screenshotsContainer.appendChild(screenshotsContainer.firstElementChild);
      });
  }
  // Add smooth scrolling to all links in class start-using-now
  $(".start-using-now a").on('click', function(event) {
    // Make sure this.hash has a value before overriding default behavior
    if (this.hash !== "") {
      // Prevent default anchor click behavior
      event.preventDefault();

      // Store hash
      var hash = this.hash;

      // Using jQuery's animate() method to add smooth page scroll
      // The optional number (800) specifies the number of milliseconds it takes to scroll to the specified area

      var my_root = $('.mdl-layout__content'); // Find the scrollable section of the body

      my_root.animate({
        scrollTop: $(hash).offset().top
      }, 800, function(){

        // Add hash (#) to URL when done scrolling (default click behavior)
        window.location.hash = hash;
      });
    } // End if
  });


  var dialog1 = document.querySelector('#dialog1');
  var dialog2 = document.querySelector('#dialog2');
  var dialog3 = document.querySelector('#dialog3');
  dialog1.style.width = '90%';
  dialog2.style.width = '90%';
  dialog3.style.width = '90%';
  if (! dialog1.showModal) {
    dialogPolyfill.registerDialog(dialog1);
  }
  if (! dialog2.showModal) {
    dialogPolyfill.registerDialog(dialog2);
  }
  if (! dialog3.showModal) {
    dialogPolyfill.registerDialog(dialog3);
  }
  var showDialog1Button = document.querySelector('#show-dialog1');
  var showDialog2Button = document.querySelector('#show-dialog2');
  var showDialog3Button = document.querySelector('#show-dialog3');
  showDialog1Button.addEventListener('click', function() {
    dialog1.showModal();
  });
  showDialog2Button.addEventListener('click', function() {
    dialog2.showModal();
  });
  showDialog3Button.addEventListener('click', function() {
    dialog3.showModal();
  });
  dialog1.querySelector('.close').addEventListener('click', function() {
    dialog1.close();
  });
  dialog2.querySelector('.close').addEventListener('click', function() {
    dialog2.close();
  });
  dialog3.querySelector('.close').addEventListener('click', function() {
    dialog3.close();
  });

});
