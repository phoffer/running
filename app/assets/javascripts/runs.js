$(document ).ready(function() {

  $(document).on('click', '.get', function(e) {
    var run_id = $(this).parents('tr.run').attr('id');
    var url = $(this).attr('href').split("/")[1];
    // alert(url);
    // alert(run_id);
    $.ajax({
      type: "POST",
      url: "/" + url,
      data: {
        run_id: run_id
      },
      dataType: 'html',
      error: function(data) {
        alert(data);
      },
      success: function(data) {
        // alert(run_tr);
        // alert(data);
        // alert(run_tr.attr('id'));
        $('#'+run_id).html(data);
      }
    });
    return false;
    // $(this).slideUp();
  });
  $('#retrieve_weather').click(function(e) {
    var source = document.URL;
    e.preventDefault();
    // alert(source + '/weather');
    $.ajax({
      type: "POST",
      url: source + '/weather',
      dataType: 'json',
      fail: function(data) {
        alert(source + '/weather');
        return false;
        // console.log(data);
      },
      done: function(data) {
        // alert(run_tr);
        // alert(data);
        // alert(run_tr.attr('id'));
        // $('#'+run_id).html(data);
        // Location.assign(source);
        alert('success');
        return false;
      }
    });
    // $(this).slideUp();
  });
});
