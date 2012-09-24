
			
$(document).ready(function(){
    
    //Get the selected tab, and it's URL.
    var selection = $('#tabs ul li a[href$="#content"]');
    var selection_url = selection.attr('href')
                                 .replace('#content', '');
                                 
    //Replace the #content href.
    selection.attr('href', '#content');
    
    //Create the tabs widget, and select the proper tab.
    $('#tabs').tabs({
        selected: selection.parent().index(),
    });
    
    //Make each tab a link by setting the href attribute.
    $('#tabs ul li a').each(function(){
        var url = $.data(this, 'load.tabs');
        if(url) {
            $(this).attr('href', url);
        }
        else {
            $(this).attr('href', selection_url);
        }
    });
    
    //Make sure the selected tab also behaves like a link.
    $('#tabs ul li.ui-tabs-selected a').click(function(){
        location.href = $(this).attr('href');
        return false;
    }).css('cursor', 'pointer');

	$("div.accordion").accordion({
		autoHeight: false,
		navigation: true
	});
});