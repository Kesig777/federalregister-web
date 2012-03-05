/* ajax send document to my_fr2 app and */
/* manage which icons are shown during each process of the ajax action */
function add_item_to_folder(el, menu, form) {
  el.find('.icon').toggle();
  el.find('.loader').toggle();
  
  form_data = form.serializeArray();
  form_data.push( {name: "entry[folder]", value: el.data('slug')} );

  $.ajax({
    url: form.prop('action'),
    data: form_data,
    type: "POST"
  }).success(function(response) {
      /* mark folder as containing document */
      el.removeClass('not_in_folder').addClass('in_folder');

      /* visually mark the icon as in at least one folder */
      /* and increment the document count                 */
      menu.find('.button span.icon').addClass('clipped');
      if ( el.data('slug') == "my-clippings" ) {
        update_user_clipped_document_count(stored_document_numbers);
      } 
      else {
        update_user_folder_document_count(response);
      }
    })
    .complete(function(response) {
      el.find('.loader').toggle();
      el.find('.icon').toggle();
    });
}

/* determine whether to expect a current user */
function expect_logged_in() {
  if ( readCookie('expect_logged_in') == "1" ) {
    return true;
  } else if ( readCookie('expect_logged_in') == "0") {
    return false;
  } else {
    return false;
  }
}

function insert_new_folder_into_menu(menu, response) {
  if ( $("#add-to-folder-menu-li-fr2-template") ) {
    template = Handlebars.compile( $("#add-to-folder-menu-li-fr2-template").html() );
    menu.find('.menu ul')
      .append( $(template(response)).css('opacity', 0)
        .animate({ opacity: 1.0 }, 1500)
      );
  }
}
/* used for search results, where we want the new menu to show    *
 * in the other menus on the page but need to modify the template */
function insert_new_folder_into_other_menu(menu, response) {
  if ( $("#add-to-folder-menu-li-fr2-template") ) {
    template = Handlebars.compile( $("#add-to-folder-menu-li-fr2-template").html() );
    new_li = $( template(response) );
    menu.find('.menu ul').append( new_li );
    new_li.removeClass('in_folder').addClass('not_in_folder');

    /* add events */
    new_li.find('a').bind('click', function(event) { event.preventDefault(); });
    /* enable saving to folder */
    new_li.bind('click', function(event) {
      event.preventDefault();
      add_item_to_folder( $(this), menu, menu.closest('li').find('form.add_to_clipboard') );
    });

  }
}

function update_user_util_folders(response) {
  /* NOTE: currently we do nothing with the response but will in the future */
  update_user_folder_and_document_count(response);
}

function show_clippings_menu( menu ) {
  /* turn on hover - these need to be in js or we get weird interactions between js *
  * triggered hovers and css hover states - no one wants a flickering menu         */
  menu.addClass('hover');
  }
function hide_clippings_menu( menu ) {
  menu.removeClass('hover');
  }


function display_new_folder_modal( menu, document_number ) {
  /* disable the hover menu and keep open */
  menu.unbind('mouseleave');
  menu.addClass('hover');
  menu.find('.menu li#new-folder').addClass('hover');

  /* decide which modal to show */
  if ( expect_logged_in() ) {
    modal = $('#new-folder-modal');
  } else {
    modal = $('#account-needed-modal');
  }

  /* place our data in the modal form */
  form = modal.find('form.folder');
  form.data('document-number', document_number);
  form.data('menu', menu);

  /* show the modal */
  $(modal).jqm({
      modal: true,
      toTop: true,
      onShow: myfr2_jqmHandlers.show,
      onHide: myfr2_jqmHandlers.hide
  });
  modal.centerScreen().jqmShow();
}

function create_new_folder(form) {
  menu = form.data('menu');
  document_number = form.data('document-number');

  console.log( menu, form, document_number);
  /* hide the form so we can show staus messages */
  form.hide();
  form.siblings('p').hide();

  /* show creating folder message and loader */
  $('new-folder-modal .folder_create').show();

  /* submit data and handle response or failure */
  form_data = form.serializeArray();
  form_data.push( {name: "folder[document_numbers]", value: new Array(document_number)} );

  $.ajax({
    url: form.prop('action'),
    data: form_data,
    type: "POST"
  }).success(function(response) {
      /* mark the current menu as active so that we can treat it *
       * specially when we need to                               */
      menu.data('active-menu', true);

      $('new-folder-modal .folder_create').hide();
      show_folder_success(response); 
      update_user_util_folders(response);

      /* hide the modal about 1 second after success */
      setTimeout(function () {
          $('#new-folder-modal').jqmHide();
          $('#new-folder-modal .folder_success').hide();
          form.siblings('p').show();
          form.find('input#folder_name').val('');
          form.show();
        },
        1200);
      
      /* place the new folder in the flag menu and renable hover functionality */
      setTimeout(function () {
          insert_new_folder_into_menu(menu, response);
          menu.find('.button span.icon').addClass('clipped');

          /* add new folder to all the other menus if we're on a search page */
          if ( $('body#search').length !== 0 ) {
            $('#clipping-actions.fr2 .add_to_folder').each( function() {
              other_menu = $(this);
              if ( other_menu.data('active-menu') !== true ) {
                insert_new_folder_into_other_menu( other_menu, response);
              }
            });
          }
        },
        1225);

      /* return page to a normal state */
      setTimeout(function () {
          /* re-enable our hover menu that was disabled when the 'new folder' button was clicked */
          menu.bind('mouseleave', function() {
            hide_clippings_menu( $(this) );
          });
          
          /* close the hover menu */
          hide_clippings_menu( menu );
          menu.find('.menu li#new-folder').removeClass('hover');
          menu.data('active-menu', false);
        },
        3700);
    })
    .fail(function(response) {
      $('new-folder-modal .folder_create').hide();
      form.siblings('p').show();
      form.show();
    });
}

$(document).ready(function () {
  /* hide form and prevent unwanted submission */
  $('form.add_to_clipboard').hide();
  $('form.add_to_clipboard').bind('submit', function(event) {
    event.preventeventDefault();
  });

  /* update styles on page so that our hover menu is properly viewable */
  if ( $('.metadata_share_bar').length !== 0 ) {
    $('.metadata_share_bar').height( $('.metadata_share_bar .metadata').height() ).css('overflow', 'visible');
  }

  /* get current document */
  current_document_number = $('form.add_to_clipboard input#entry_document_number').val();
  
  
  /*                    *
  *  Add to Folder Menu *
  *                     */

  /* compile template */
  if ( $("#add-to-folder-menu-fr2-template") ) {
    add_to_folder_menu_fr2_template = Handlebars.compile( $("#add-to-folder-menu-fr2-template").html() );
  }
  /* add current document number to the folder details */
  user_folder_details.current_document_number = current_document_number;
  

  $('div.share li.clip_for_later').each( function () {
    var this_document_number;
    if ( $('body#search').length !== 0 ) {
      this_document_number = $(this).closest('div').closest('li').data('document-number');
      user_folder_details.current_document_number = this_document_number;
    }

    /* place the menu on the page */
    var menu = $( add_to_folder_menu_fr2_template(user_folder_details) );
    $(this).append($('<div>').addClass("fr2").prop('id', 'clipping-actions').append( menu ) );

    /* EVENTS*/
    menu.bind('mouseenter', function() {
      show_clippings_menu( $(this) );
    });
    menu.bind('mouseleave', function() {
      hide_clippings_menu( $(this) );
    });

    /* allow icon to be clicked as a shortcut for adding current document to the clipboard */
    menu.delegate('.button .icon', 'click', function(event) {
      /* check if already in clipboard */
      not_in_clipboard = $(menu).find('.menu li[data-slug="my-clippings"].not_in_folder').length !== 0;
      if ( not_in_clipboard ) {
        $(menu).find('.menu li[data-slug="my-clippings"]').trigger('click');
      };
    });

    menu.find('.menu .li, .menu .li a').bind('click', function(event) { event.preventDefault(); }); 

    /* enable saving to folder */
    menu.find('.menu li.not_in_folder').bind('click', function(event) {
      event.preventDefault();
      add_item_to_folder( $(this), menu, menu.closest('li').find('form.add_to_clipboard') );
    });

    /* visually identify the document as flagged if its in a folder */
    if ( $('body#search').length !== 0 ) {
      if( user_folder_details !== undefined && document_number_present(this_document_number, user_folder_details) ) {
        menu.find('.button span.icon').addClass('clipped');
      }
    }

    /* new folder functionality */
    menu.find('.menu li#new-folder').bind('click', function(event) {
      event.preventDefault();
      display_new_folder_modal( menu, this_document_number );
    });

   

    $("#new-folder-modal .new_folder_close").bind('click', function (event) {
      /* re-enable our hover menu that was disabled when the 'new folder' button was clicked */
      menu.bind('mouseleave', function() {
        hide_clippings_menu( $(this) );
      });

      /* close the hover menu */
      hide_clippings_menu( menu );
      menu.find('.menu li#new-folder').removeClass('hover');
    });
  });
  

  /* visually identify the document as flagged if its in a folder */
  /* this is used on the article page - search is handled above  */
  if ( $('body#search').length === 0 ) {
    if( user_folder_details !== undefined && document_number_present(current_document_number, user_folder_details) ) {
      $('div.share li.clip_for_later #add-to-folder .button span.icon').addClass('clipped');
    }
  }

 $('#new-folder-modal form.folder').live('submit', function(event) {
    event.preventDefault();
    create_new_folder( $(this) );
  });

  /* add tipsy to the menu(s) */
  $('.add_to_folder .button.tip_over').tipsy({gravity:'south', offset: 3, live: true});
});
