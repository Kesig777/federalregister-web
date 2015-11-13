/* global modalOpen */
$(document).ready(function () {
    $('a.load_facet').live('click',
    function () {
        var anchor = $(this);
        $(this).after('<img src="/images/ui/ui-anim_basic_16x16.gif" />');
        var facet_name = anchor.attr('data-facet-name');
        var url = $(location).attr('href').replace('/search?', '/search/facets/' + facet_name + '?all=1&');
        $.ajax({
            url: url,
            success: function (data) {
                anchor.closest('ul').html(data);
            }
        });

        return false;
    });

    //Add in some helpful hints that would be redundant if we had all the labels displaying
    $(".range_start input").after("<span> to </span>");
    $(".cfr li:first-child input").after("<span> CFR </span>");
    $(".zip li:first-child input").after("<span> within </span>");
});
