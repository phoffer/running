$(document ).ready(function() {

  $('.retrieve_weather').click(function(e) {
    var source = document.URL;
    // alert($(this).attr('href') + '.json');
    e.preventDefault();
    e.stopPropagation();
    $.post($(this).attr('href') + '.json', {
      // type: "POST",
      dataType: 'json'
    }).fail(function(data) {
    }).done(function(data) {
      // fill in data. runs#index, runs#show
    })
    // $(this).slideUp();
  });
});
