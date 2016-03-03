//= require dropzone

Dropzone.autoDiscover = false;

document.addEventListener('turbolinks:load', Dropzone.discover);

Dropzone.options.dataDistributionDropZone = {
  paramName: "data_distribution[file]",
  maxFilesize: 4096,
  dictDefaultMessage: "Drop files or click here to upload",

  init: function() {

    var uploadedFiles = [];

    $('#sin-cancel-upload').click(function(e) {
      if (this.disabled) return;
      // alert(uploadedFiles);
      uploadedFiles.forEach(function(file)  {
        // alert(file['@id'])
        $.ajax({
          url: file['@id'],
          dataType: 'json',
          type: 'DELETE'
          // success: function(lol) {
            // alert(lol);
            // console.log(lol)
          // }
        });
      });
      // e.preventDefault();
    });

    this.on("success", function(file, data) {
      if (data) {
        if (data["sin:extension"]) {
          // file.previewTemplate.appendChild(document.createTextNode(data["sin:extension"]));
          file.previewTemplate.classList.add('sin-preview-filetype-'+data["sin:extension"]);
        }

        $('.sin-drop-switchable-disabled').removeAttr('disabled');
        uploadedFiles.push(data);

      }
    });
  }
};
