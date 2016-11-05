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

Dropzone.options.filestoreDropZone = {
  paramName: "filestore[file]",
  maxFilesize: 4096,
  uploadMultiple : false,
  maxFiles : 1,
  dictDefaultMessage: "Drop file or click here to upload",

  init: function() {

    var uploadedFiles = [];
    console.log("Running init function");

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
        debugger;
        console.log("Success url : "+data["@id"]);
        if (data["sin:extension"]) {
          // file.previewTemplate.appendChild(document.createTextNode(data["sin:extension"]));
          file.previewTemplate.classList.add('sin-preview-filetype-'+data["sin:extension"]);
        }

        $('.sin-drop-switchable-disabled').removeAttr('disabled');
        uploadedFiles.push(data);

      }
    });

    this.on("maxfilesexceeded", function(file) {
       this.removeFile(file);
    });

  },

  accept: function(file, done) {
    var ext = file.name.split('.').pop();
    var acceptRdf = false;
    var acceptFilestore = false;
    console.log("Accept file : "+file.name+" ext :"+ext);
    if (ext == 'rdf') {
      acceptRdf = true;
    } else if (ext == 'xls') {
      acceptFilestore = true;
    } else if (ext == 'xlsx') {
      acceptFilestore = true;
    } else if (ext == 'csv') {
      acceptFilestore = true;
    } else if (ext == 'tsv') {
      acceptFilestore = true;
    }


    console.log("Has URL : "+this.options.url);
    var endOfUrl = this.options.url.split("/").pop();
    if (acceptRdf) {
      console.log("Accept RDF : ".concat(file.name));
      this.options.url = this.options.url.replace(endOfUrl, 'sparqlendpoints');
      done();
    } else if (acceptFilestore) {
      console.log("Accept filestore : ".concat(file.name));
      this.options.url = this.options.url.replace(endOfUrl, 'filestores');
      done();
    } else {
      window.alert('Error Datagraft does not support the file format <'+ext+'> of your uploaded file. Supported file formats: CSV, TSV, XLS or XLSX, RDF/XML, Turtle, N-Triples, N-quads, N3, JSON-LD');
      done('Error filetype <'+ext+'> is not supported');
      this.removeFile(file);
    }
    console.log("NewUrl : "+this.options.url);
  }


};

Dropzone.options.upwizardDropZone = {
  paramName: "upwizard[file]",
  maxFilesize: 4096,
  uploadMultiple : false,
  maxFiles : 1,
  dictDefaultMessage: "Drop file or click here to upload",

  init: function() {

    var uploadedFiles = [];
    console.log("Running init function");

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
        //debugger;
        console.log("Success url : "+data["@id"]);
        if (data["sin:extension"]) {
          // file.previewTemplate.appendChild(document.createTextNode(data["sin:extension"]));
          file.previewTemplate.classList.add('sin-preview-filetype-'+data["sin:extension"]);
        }

        $('.sin-drop-switchable-disabled').removeAttr('disabled');
        uploadedFiles.push(data);
        window.location = data["@id"];

      }
    });

    this.on("maxfilesexceeded", function(file) {
      window.alert('Error only one file can be handled in this dialog');
      this.removeFile(file);
    });

  },

  accept: function(file, done) {
    var ext = file.name.split('.').pop();
    var acceptedFile = false;
    console.log("Accept file : "+file.name+" ext :"+ext);
    if (ext == 'rdf') {
      acceptedFile = true;
    } else if (ext == 'nt') {
      acceptedFile = true;
    } else if (ext == 'ttl') {
      acceptedFile = true;
    } else if (ext == 'n3') {
      acceptedFile = true;
    } else if (ext == 'trix') {
      acceptedFile = true;
    } else if (ext == 'trig') {
      acceptedFile = true;
    } else if (ext == 'xls') {
      acceptedFile = true;
    } else if (ext == 'xlsx') {
      acceptedFile = true;
    } else if (ext == 'csv') {
      acceptedFile = true;
    } else if (ext == 'tsv') {
      acceptedFile = true;
    }

    if (acceptedFile) {
      console.log("Accept file: ".concat(file.name));
      done();
    } else {
      window.alert('Error filetype <'+ext+'> is not supported');
      done('Error filetype <'+ext+'> is not supported');
      this.removeFile(file);
    }
  }


};
