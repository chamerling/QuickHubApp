(function($){

  $.each($('.post.link.github h3 a'), function() {
    var post = $(this).parents(".post");
    var url = $(this).attr('href');
    var segments = url.split('/');
    var repo = segments.pop();
    var username = segments.pop();
    $.getJSON("http://github.com/api/v2/json/repos/show/"+username+"/"+repo+"?callback=?", function(data){
      var repo_data = data.repository;
      if(repo_data) {
        var watchers_link = $('<a>').addClass('watchers').attr('href', url+'/watchers').text(repo_data.watchers);
        var forks_link = $('<a>').addClass('forks').attr('href', url+'/network').text(repo_data.forks);
        var comment_link = post.find('.meta .comment-count');
        comment_link.after(watchers_link);
        comment_link.after(forks_link);
      }
    });
  });
})(jQuery);