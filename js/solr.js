var Manager;

(function ($) {

    $(function () {
        Manager = new AjaxSolr.Manager({
            solrUrl: 'http://ec2-54-226-122-231.compute-1.amazonaws.com:8081/solr/'
        });
        <!-- Every widget takes a required id, to identify the widget,and an optional target. -->
        <!-- The target is usually the CSS selector for the HTML element that the widget updates   -->
        <!-- after each Solr request.-->
        Manager.addWidget(new AjaxSolr.ResultWidget({
            id: 'result',
            target: '#docs'
        }));

        Manager.addWidget(new AjaxSolr.TextWidget({
            id: 'text',
            target: '#search'
        }));

        Manager.init();
        Manager.store.addByValue('q', '*:*');
        //Manager.doRequest();
    });

})(jQuery);