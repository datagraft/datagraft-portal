//= require dropzone

Dropzone.autoDiscover = false;

document.addEventListener('page:change', Dropzone.discover);

Dropzone.options.dataDistributionDropZone = {
  paramName: "data_distribution[file]",
  maxFilesize: 4096,

  init: function() {
    this.on("success", function(file, data) {
      if (data && data.file_content_type) {
        file.previewTemplate.appendChild(document.createTextNode(data.extension));
        file.previewTemplate.classList.add('sin-preview-filetype-'+data.extension);
      }
      // Handle the responseText here. For example, add the text to the preview element:
    });
  }
};
