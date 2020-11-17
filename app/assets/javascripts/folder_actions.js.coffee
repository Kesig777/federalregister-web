$(document).ready ->
  $('#delete-folder').on 'click', (event)->
    event.preventDefault()

    folderData = {
      numClippings: $('#clippings li').length,
      folderSlug: $('h2.title').data().folderSlug,
      token: $('meta[name="csrf-token"]').attr('content')
    }

    modalTemplate = Handlebars.compile $("#delete-folder-modal-template").html()

    FR2.Modal.displayModal(
      "", modalTemplate(folderData),
      {
        includeTitle: false,
        modalClass: 'delete-folder-modal'
      }
    )

    $('.delete-folder-modal .delete-folder-modal-button').on 'click', (e)->
      $(this).closest('form').submit()
