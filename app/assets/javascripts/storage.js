function update_user_clipped_document_count(stored_documents) {
  //document_count = stored_documents !== undefined ? Object.keys(stored_documents).length : 0; 
  document_count = parseInt( $('#document-count #doc_count').html() );
  $('#document-count #doc_count').html( document_count + 1 );
}

function update_user_folder_count(folder_object) {
  folder_count = parseInt( $('#document-count-holder #user_folder_count').html() );
  $('#user_folder_count').html( folder_count + 1 );
  }

function update_user_folder_document_count(folder_object) {
  folder_docs_count = parseInt( $('#document-count-holder #user_documents_in_folders_count').html() );
  $('#user_documents_in_folders_count').html( folder_docs_count + 1 );
  }

function update_user_folder_and_document_count(folder_object) {
  update_user_folder_count(folder_object);
  update_user_folder_document_count(folder_object);
  }

function document_number_present(document_number, user_folder_details) {
  return _.filter( user_folder_details.folders, function(folder) {
    /* return the folder if it has the document in it */
    return $.inArray( current_document_number, folder.documents) > -1;
  }).length !== 0;
}

function closeOnEscape(hash) {
  $(window).one('keyup', function(event) {
    if( event.keyCode === '27' ){
      hash.w.jqmHide();
    }
  });
}

var myfr2_jqmHandlers = {
  href: "",
  timer: "",
  show: function (hash) {
      hash.w.show();
      closeOnEscape(hash);
  },
  hide: function (hash) {
      hash.w.hide();
      hash.o.remove();
  }
};
