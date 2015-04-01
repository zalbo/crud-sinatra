$( document ).ready(function() {

  //Delete image
  $('#img-x').click(function(){
    $('#img').hide();
    $('#img-x').hide();
    $('#img-check').prop('checked', true);

    $('#img-chosefile').show();
  })

  //Search in index
  $("#search-btn").click(function(event){
    event.preventDefault();
    var word = $("#search-txt").val()
    $.get( "/?search="+ word + "", function( data ) {
      $( "body" ).html( data );
    });
  })

  if( $("#img").length  ) {
    $('#img-chosefile').hide();
  }

});
