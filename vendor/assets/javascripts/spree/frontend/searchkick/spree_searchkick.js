// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
//= require_tree .

Spree.typeaheadSearch = function() {
  var products = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 10,
    // prefetch: Spree.pathFor('autocomplete/products.json'),
    remote: {
      url: Spree.pathFor('autocomplete/products.json'),
      wildcard: '%QUERY',
      prepare: function(query, settings) {
        settings.url += '?keywords=' + query;
        return settings;
      },
    }
  });

  products.initialize();

  // passing in `null` for the `options` arguments will result in the default
  // options being used

  $('#keywords').typeahead({
    minLength: 2,
    highlight: true,
  }, {
    displayKey: 'name',
    source: products.ttAdapter(),
    templates:{
      suggestion:function(products) {
        return "<a class = 'text-dark text-decoration-none d-block' href=/products/" + products.split(":::", 2)[1] + "> <div role= 'option'>"+ products.split(":::", 2)[0] +"</div> </a>"
      }
    }
  });
}
