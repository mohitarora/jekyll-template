(function ($) {

AjaxSolr.ResultWidget = AjaxSolr.AbstractWidget.extend({
  start: 0,

  beforeRequest: function () {
    $(this.target).html($('<img>').attr('src', '/images/ajax-loader.gif'));
  },

  afterRequest: function () {
    $(this.target).empty();
    //If there are no search results, show no results and a link to home page.
    if(this.manager.response.response.docs.length == 0)
    {
        $(this.target).html(this.noResult())
    }
    else
    {
        for (var i = 0, l = this.manager.response.response.docs.length; i < l; i++) {
          var doc = this.manager.response.response.docs[i];
          $(this.target).append(this.template(doc));
        }
    }
  },

  template: function (doc) {
    var output = '<div><h2><a href=\"' + doc.id + '\">'+ doc.title + '</a></h2>';
    output += '</div>';
    return output;
  },

  noResult: function() {
      var output = '<div>No Results found...Go Back to <a href=\"/\">list</a> of documents or search again.</div>'
      return output;
  }


});

})(jQuery);