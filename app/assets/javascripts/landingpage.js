
document.addEventListener('turbolinks:load', function() {

  // Screenshots carousel
  var screenshotsContainer = document.getElementById("screenshots-container");

  if (!screenshotsContainer) return;

  screenshotsContainer.addEventListener("click", function() {
      screenshotsContainer.insertBefore(screenshotsContainer.lastElementChild, screenshotsContainer.firstElementChild);
  });

});
