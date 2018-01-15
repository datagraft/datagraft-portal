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
      uploadedFiles.forEach(function(file)  {
        $.ajax({
          url: file['@id'],
          dataType: 'json',
          type: 'DELETE'
        });
      });
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
      uploadedFiles.forEach(function(file)  {
        $.ajax({
          url: file['@id'],
          dataType: 'json',
          type: 'DELETE'
        });
      });
    });

    this.on("success", function(file, data) {
      if (data) {
        debugger;
        console.log("Success url : "+data["@id"]);
        if (data["sin:extension"]) {
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
    console.log("Running upwizard dropzone init function");

    var x = document.querySelectorAll('.sin-drop-switchable-tab-hidden');
    var i;
    //debugger;
    for (i = 0; i < x.length; i++) {
      x[i].style.display = 'none';
    }
    console.log("hiding .tab occurences " + i);

    x = document.querySelectorAll('.sin-drop-switchable-rdf-hidden');
    //debugger;
    for (i = 0; i < x.length; i++) {
      x[i].style.display = 'none';
    }
    console.log("hiding .rdf occurences " + i);

    $('#sin-cancel-upload').click(function(e) {
      if (this.disabled) return;
      // alert(uploadedFiles);
      uploadedFiles.forEach(function(file)  {
        $.ajax({
          url: file['@id'],
          dataType: 'json',
          type: 'DELETE'
        });
      });
    });

    this.on("success", function(file, data) {
      if (data) {
        //console.log("Success for file: "+file.name);
        //debugger;
        //console.log("Success url : "+data["@id"]);
        if (data["sin:extension"]) {
          // file.previewTemplate.appendChild(document.createTextNode(data["sin:extension"]));
          file.previewTemplate.classList.add('sin-preview-filetype-'+data["sin:extension"]);
        }

        var ext = file.name.split('.').pop();
        var rdfFile = false;
        var tabFile = false;
        console.log("Checking file : "+file.name+" ext :"+ext);
        if (ext == 'rdf') {
          rdfFile = true;
        } else if (ext == 'nt') {
          rdfFile = true;
        } else if (ext == 'ttl') {
          rdfFile = true;
        } else if (ext == 'n3') {
          rdfFile = true;
        } else if (ext == 'trix') {
          rdfFile = true;
        } else if (ext == 'trig') {
          rdfFile = true;
        } else if (ext == 'xls') {
          tabFile = true;
        } else if (ext == 'xlsx') {
          tabFile = true;
        } else if (ext == 'csv') {
          tabFile = true;
        } else if (ext == 'tsv') {
          tabFile = true;
        }

        if(tabFile) {
          var x = document.querySelectorAll('.sin-drop-switchable-tab-hidden');
          var i;
          for (i = 0; i < x.length; i++) {
            x[i].removeAttribute("style");
          }
          console.log("showing .tab occurences " + i);
        }
        if(rdfFile) {
          var x = document.querySelectorAll('.sin-drop-switchable-rdf-hidden');
          var i;
          for (i = 0; i < x.length; i++) {
            x[i].removeAttribute("style");
          }
          console.log("showing .rdf occurences " + i);
        }
        uploadedFiles.push(data);

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
