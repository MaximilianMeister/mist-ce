define('app/views/file_upload', ['app/views/templated', 'ember'],
    //
    //  File Upload View
    //
    //  @returns Class
    //
    function(TemplatedView) {

        'use strict';

        return TemplatedView.extend({



            //
            //
            //  Actions
            //
            //


            actions: {

                uploadClicked: function () {
                    if (window.File && window.FileReader && window.FileList) {
                        // Dynamically click the hidden input
                        // field to present the folder dialog
                        $('#file-upload-input').click();
                    } else {
                        Mist.notificationController.notify('Your browser does not support the HTML5 file API');
                    }
                },


                uploadInputChanged: function () {
                    Mist.fileUploadController.uploadFile($('#file-upload-input')[0].files[0]);
                },


                backClicked: function () {
                    Mist.fileUploadController.close();
                },


                doneClicked: function () {
                    Mist.fileUploadController.confirmUpload();
                }
            }
        });
    }
);
