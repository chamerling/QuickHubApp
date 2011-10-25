jQuery(document).ready(function($){

  $('#github').mouseover(function(){
    $('#mousing').text("GitHub");
  });

  $('#github').mouseout(function(){
    $('#mousing').html("&nbsp;");
  });

  $('#twitter').mouseover(function(){
    $('#mousing').text("Twitter");
  });

  $('#twitter').mouseout(function(){
    $('#mousing').html("&nbsp;");
  });

  $('#rss').mouseover(function(){
    $('#mousing').text("RSS");
  });

  $('#rss').mouseout(function(){
    $('#mousing').html("&nbsp;");
  });

// dropdown menu
$("body").bind("click", function (e) {
  $('a.menu').parent("li").removeClass("open");
});

$("a.menu").click(function (e) {
  var $li = $(this).parent("li").toggleClass('open');
  return false;
});


});
