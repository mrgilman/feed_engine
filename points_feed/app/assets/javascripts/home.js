function bounce_login(){
  jQuery(".pull-right").animate({
    backgroundColor: "#FFFFFF"
  }, 'slow');

  jQuery(".pull-right").animate({
    backgroundColor: "#000000"
  }, 'slow');

}
//setInterval(function(){
//  bounce_login();
//  }, 5000);




// $('#login-link').click(function(){
//   $('#login-colorbox').show();
// });

$('#login-link').colorbox(
  { inline: true, 
    href: '#login-colorbox'}
);

// $(document).bind("cbox_closed", function() {
//   $('#login-colorbox').hide();
// });

