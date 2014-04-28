function chars_remaining(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      max_chars = $li.data('max-size'),
      used_chars;

  if( $input.val() !== "" ) {
    used_chars = $input.val().length;
  } else {
    used_chars = 0
  }

  return max_chars - used_chars;
}

function add_char_count_error(input) {
  var  $input = $(input),
       $li = $input.closest('li'),
       warn_threshold = $li.data('size-warn-at');

  if( $li.hasClass('string') && warn_threshold !== undefined ) {
    return chars_remaining(input) <= warn_threshold;
  } else {
    return false
  }
}

function update_character_count(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      error_field = $input.siblings('p.inline-errors').first(),
      remaining = chars_remaining($input),
      text = remaining == 1 ? ' character left' : ' characters left';

  if( add_char_count_error($input) ) {
    if( error_field.length === 0 ) {
      $input.after( $('<p>').addClass('inline-errors') );
      error_field = $input.siblings('p.inline-errors').first();
    }

    error_field.text( remaining + text );
  } else {
    if( error_field.length !== 0 ) {
      error_field.text('');
      error_field.remove();
    }
  }
}

function visually_notify_user(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      remaining = chars_remaining($input),
      error_field = $input.siblings('p.inline-errors').first();

  if( remaining < 0 ) {
    $li.addClass('error');
  } else {
    $li.removeClass('error');
  }

  if( remaining >= 0 ) {
    error_field.addClass('warning');
  } else {
    error_field.removeClass('warning');
  }
}

function enforce_characters_remaining(el) {
  var input = $(el).find('input');

  update_character_count(input);
  visually_notify_user(input);
}

function validate_field(el) {
  var $el = $(el),
      $input = $el.find('input');

  if( $input !== undefined && $input.val() !== undefined ) {
    if( !add_char_count_error($input) && $input.val().length > 0 ) {
      $el.removeClass('error');
      $el.find('p.inline-errors').text('');
    }
  }
}
