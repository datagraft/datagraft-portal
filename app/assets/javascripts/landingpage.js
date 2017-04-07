
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


  var show_ovl1 = document.querySelector('#show-ovl1');
  if(show_ovl1) {
    show_ovl1.addEventListener('click', function() {
      document.querySelector("#ovl1").style.display = "block";
    });
  }
  var close_ovl1 = document.querySelector('#close-ovl1');
  if(close_ovl1) {
    close_ovl1.addEventListener('click', function() {
      document.querySelector("#ovl1").style.display = "none";
    });
  }
  var show_ovl2 = document.querySelector('#show-ovl2');
  if(show_ovl2) {
    show_ovl2.addEventListener('click', function() {
      document.querySelector("#ovl2").style.display = "block";
    });
  }
  var close_ovl2 = document.querySelector('#close-ovl2');
  if(close_ovl2) {
    close_ovl2.addEventListener('click', function() {
      document.querySelector("#ovl2").style.display = "none";
    });
  }
  var show_ovl3 = document.querySelector('#show-ovl3');
  if(show_ovl3) {
    show_ovl3.addEventListener('click', function() {
      document.querySelector("#ovl3").style.display = "block";
    });
  }
  var close_ovl3 = document.querySelector('#close-ovl3');
  if(close_ovl3) {
    close_ovl3.addEventListener('click', function() {
      document.querySelector("#ovl3").style.display = "none";
    });
  }

});
