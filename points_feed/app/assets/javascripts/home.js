function bounce_login(){
  jQuery(".pull-right").animate({
    backgroundColor: "#FFFFFF"
  }, 'slow');

  jQuery(".pull-right").animate({
    backgroundColor: "#000000"
  }, 'slow');

}



setInterval(function(){
  bounce_login();
  }, 5000);
