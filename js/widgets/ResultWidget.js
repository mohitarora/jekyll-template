(function ($) {

AjaxSolr.ResultWidget = AjaxSolr.AbstractWidget.extend({
  start: 0,

  beforeRequest: function () {
    //$(this.target).html($('<img>').attr('src', '/images/ajax-loader.gif'));
  },

  afterRequest: function () {
    //If there are no search results, show no results and a link to home page.
    if(this.manager.response.response.docs.length == 0)
    {
        $(this.target).empty();
        $(this.target).html(this.noResult())
    }
    else if(this.manager.response.response.docs.length == 1)
    {
        document.location.href = this.manager.response.response.docs[0].id;
    }
    else
    {
        $(this.target).empty();
        var queryText = this.manager.response.responseHeader.params.q;
        queryText = queryText.substring(14, queryText.length - 1);
        $(this.target).html('<h2>Documents with search text: ' + queryText + '</h2>')
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