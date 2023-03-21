function setup_previewable_nav(el) {
    /* hide all other sections and show the first */
    var nav_sections = el.closest('.dropdown');
    nav_sections.find('.left_column li').children('a').removeClass('hover');
    nav_sections.find('.left_column li').first().find('a').addClass('hover');
    nav_sections.find('.right_column').children('li').hide();
    var preview = nav_sections.find('.right_column li').first();
    preview.show();

    preview.find('.carousel-rounded-box').trigger('show');
}

// New Mobile Navbar Handling
//=====================================================================
document.addEventListener('DOMContentLoaded', function() {
  
  // Handle toggling of subnav
  var toggleableList = document.querySelectorAll('#navigation .container > li.dropdown');
  toggleableList.forEach(function(item) {
    item.addEventListener('click', function(event) {
        var el = event.target.closest('li');
        if (el === item) { // ie make sure we're only handling clicks to the subnav item (eg 'Browse', 'Sections', etc)
          event.preventDefault();
          if (el.classList.contains('active')) {
            el.classList.remove('active');
            event.target.classList.remove('active');
          } else {
            el.classList.add('active');
            event.target.classList.add('active');
          }
        }
      // }
    });
  });

  // Hide non-essential nav components when viewport width is reduced
  var navCollapsingHandler = function () {
    var hamburgerIsCollapsed = !$("#navigation").hasClass("hamburger-expanded");
    if ((window.innerWidth <= 500) && hamburgerIsCollapsed) {
      $('#navigation li.dropdown').each(function() { $(this).hide(); } );
    } else {
      $('#navigation li.dropdown').each(function() { $(this).show(); } );
    }
  };
  // Run on page load to ensure nav is constrained if viewport is already limited
  navCollapsingHandler();
  window.addEventListener('resize', function() {
    navCollapsingHandler();
  });

  // Handle clicks on hamburger icon
  var menuIcon = document.querySelector('#nav-hamburger');
  menuIcon.addEventListener('click', function (e) {
    e.preventDefault();
    document.getElementById('navigation').classList.toggle('hamburger-expanded');
    $('#navigation li.dropdown').each(function() { $(this).toggle(); });
  });

});
//=====================================================================

$(document).ready( function() {
  // NOTE: Most of this code can likely be removed since it deals with the concept of left and right navigation submenu, which will not exist in the future.
  if (true) {
    return;
  }

  var navigation_timeout = null;

  $('#navigation .dropdown').bind('mouseenter', function(event) {
    var dropdown = $(this);
    /* ensure other menus close - this covers odd edge cases that
     * bypass mouseleave (opening another tab, switching apps, etc). */
    /* also, shouldn't need the added find scope after siblings -
     * but IE requires it or you get a big nasty loop... */
    dropdown.siblings().find('.dropdown').trigger('mouseleave');

    dropdown.find('a.top_nav').addClass('hover');
    dropdown.find('.subnav').show();

    if( dropdown.hasClass('nav_sections') || dropdown.hasClass('nav_browse') || dropdown.hasClass('nav_blog') ) {
      setup_previewable_nav( dropdown.find('a.top_nav') );
    }
  });

  $('#navigation .dropdown').bind('mouseleave', function(event) {
    $(this).find('.subnav').hide();
    $(this).find('a.top_nav').removeClass('hover');
  });

  $('#navigation .subnav .left_column a').bind('click', function(event) {
    /* this is to support touch enabled devices where the first click
     * is actually a hover on these menus */
    if( ! $(this).hasClass('hover') ) {
      event.preventDefault();
    }
  });

  $('#navigation .subnav').bind('mouseenter', function() {
    $(this).closest('.dropdown').find('a.top_nav').addClass('hover');
  });

  $('#navigation .subnav').bind('mouseleave', function() {
    $(this).closest('.dropdown').find('a.top_nav').removeClass('hover');
    $(this).hide();

    /* check to see if the mouse pointer in now over the main navigation dropdowns,
     * if it is then trigger mouseenter once more (it doesn't fire by default because
     * subnav's are containted within the dropdown and thus haven't left yet...) */
    if( $(document.elementFromPoint(event.clientX, event.clientY)).parent().hasClass('dropdown') ) {
      $(document.elementFromPoint(event.clientX, event.clientY)).parent().trigger('mouseenter');
    }
  });

  $('#navigation .subnav .left_column li').bind('mouseenter', function() {
    /* set timeouts so that menu items show only if the mouseenter event was
     * intentional, not an inadvertant hover on the way to the right side of
     * the menu */
    var el = $(this);
    navigation_timeout =  setTimeout( function() {
                            /* set hover states properly */
                            el.closest('.left_column').find('li a').removeClass('hover');
                            el.find('a').addClass('hover');

                            /* show right side */
                            $('#navigation .subnav .right_column li.preview').hide();
                            var preview = $('#navigation .subnav .right_column').find('#' + el.attr('id') + '-preview');
                            preview.show();
                            preview.find('.carousel-rounded-box').trigger('show');
                            //setup_preview_scroller( preview.find('.text_wrapper') );
                          }, 300);

  });

  $('#navigation .subnav .left_column li').bind('mouseleave', function() {
    $('.ui-autocomplete.ui-menu').hide();
    clearTimeout( navigation_timeout );
  });

  $('#navigation .subnav .right_column li .calendar-wrapper ').bind('mouseenter', function(event) {
    event.stopPropagation();
    event.preventDefault();
  });

  /* Setup calendar as appropriate for navigation view */
  $('#navigation .previewable table.calendar').addClass('no_select');
  $('#navigation .previewable table.cal_first').find('.cal_next').html('');
  $('#navigation .previewable table.cal_last').find('.cal_prev').html('');

  // Setup the section navigation preview carousels
  _.each($('.carousel-nav .carousel-wrapper'), function(carouselWrapper) {
    new FR2.CarouselScroller(carouselWrapper);
  });

  // Setup the agency and topic autocompleters
  _.each($('#navigation form.facet-explorer-search'), function(form) {
    new FR2.Autocompleter( $(form) );
  });
});
