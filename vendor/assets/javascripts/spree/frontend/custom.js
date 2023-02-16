document.addEventListener('turbolinks:load', function () {
  $('#product-properies-arrow').click(function () {
    elements = document.getElementsByClassName('extended')
    for (i=0; i< elements.length; i++) { elements[i].classList.remove('d-none'); }

    let propertyArrow = document.getElementById('product-properies-arrow');
    propertyArrow.classList.remove('d-flex');
    propertyArrow.classList.add('d-none');
  })

  $(window).one('resize scroll', function () {
    Spree.fetchProductsData('identical')
  })

  var relation_types = ['accessories', 'similar']
  relation_types.forEach(function(relation) {
    $('#nav-'+ relation +'-tab').one('click', function () {
      Spree.fetchProductsData(relation)
    })
  })

  $('#terms').click(function () {
    $('#checkout_submit').attr("disabled", !this.checked);
  })
})

Spree.fetchProductsData = function (relation_type) {
  var productDetailsPage = $('body#product-details')

  if (productDetailsPage.length) {
    var productId = $('div[data-' + relation_type  +'-products]').attr('data-'+relation_type +'-products-id')
    var relatedProductsEnabled = $('div[data-'+relation_type +'-products]').attr('data-'+relation_type +'-products-enabled')
    var relatedProductsFetched = false
    var relatedProductsContainer = $('#'+relation_type +'-products')

     if (!relatedProductsFetched && relatedProductsContainer.length && relatedProductsEnabled && relatedProductsEnabled === 'true' && productId !== '') {
      Spree.fetchProducts(productId, relatedProductsContainer, relation_type)
      relatedProductsFetched = true
    }
  }
}

Spree.fetchProducts = function (id, htmlContainer, method) {
  return $.ajax({
    url: '/products/'+ id + '/' + 'related_products',
    data: {
      relation_type: method
    }
  }).done(function (data) {
    htmlContainer.html(data)
  })
}

document.addEventListener('turbolinks:load', function () {
  var deleteAddressLinks = document.querySelectorAll('.js-delete-bank-account-link');
  if (deleteAddressLinks.length > 0) {
    deleteAddressLinks.forEach(function(deleteLink) {
      deleteLink.addEventListener('click', function(e) {
        document.querySelector('#overlay').classList.add('shown');
        document.querySelector('#delete-bank-account-popup').classList.add('shown');
        document.querySelector('#delete-bank-account-popup-confirm').href = e.currentTarget.dataset.bankaccount;
      }, false)
    })
  }

  document.querySelector('#overlay').addEventListener('click', function () {
    var addressActionElement = document.querySelector('#delete-bank-account-popup');
    if (addressActionElement) addressActionElement.classList.remove('shown');
  }, false);

  var popupCloseButtons = document.querySelectorAll('.js-delete-bank-account-popup-close-button')
  if (popupCloseButtons.length > 0) {
    popupCloseButtons.forEach(function(closeButton) {
      closeButton.addEventListener('click', function(e) {
        document.querySelector('#overlay').classList.remove('shown');
        document.querySelector('#delete-bank-account-popup').classList.remove('shown');
      })
    })
  }
})

document.addEventListener('turbolinks:load', function () {
  $('#nav-newsletter-tab').one('click', function () {
    var store_list_rows = document.getElementById("store_list_id").rows

    for (var i = 0; i < store_list_rows.length; i++) {
      store_id = store_list_rows[i].id.split("_")[2]
      url = '/subcriptionstatus'

      $.ajax({
        type: 'GET',
        url: url,
        data: {
          id: store_id
        },
        dataType: 'json'
      }).done(function (response) {
        if (response[0] == "Subscribed") {
          $("#remove_span_"+response[1]).find("span").remove();
          $("#unsubscribe_"+response[1]).removeClass("d-none");
         }
        else {
          $("#remove_span_"+response[1]).find("span").remove();
          $("#subscribe_"+response[1]).removeClass("d-none");
         }
      })
    }
  })
})

$(document).mouseup(function(e)
{
  var container = $(".dropdown-content");
  // if the target of the click isn't the container nor a descendant of the container
  if (!container.is(e.target) && container.has(e.target).length === 0)
  {
    container.hide();
  }
});

/* filter JS */
document.addEventListener('turbolinks:load', function () {
  var filterItems = ['plp-filters-card-item', 'plp-overlay-card-item1'];

  filterItems.forEach(function(filterItem){
    $('.'+filterItem).on('click', function(e) {
      toggleSelection(e, filterItem);
    });
  })

  function toggleSelection(e, className) {
    $(e.currentTarget).find(':checkbox').prop('checked', function(i, checked) {
      if (checked) $(this).parent().removeClass(className+'--selected').addClass(className)
      else $(this).parent().removeClass(className).addClass(className+'--selected')

      return !checked;
    });
  }
})

Spree.fetchCompData = function (id, htmlContainer) {
  return $.ajax({
    url: '/products/'+ id + '/' + 'competitor_prices',
    data: {
    }
  }).done(function (data) {
    htmlContainer.html(data)
  })
}

$('#prod-ratings').click( function(){
   $('#nav-tab a').removeClass('active show')
   $('#nav-tabContent div[role="tabpanel"]').removeClass('active show')
   $("#nav-product-reviews-tab").addClass("active show")[0].scrollIntoView();
   $("#nav-product-reviews").addClass("active show");
});

document.addEventListener('turbolinks:load', function () {
  var solotodoPresent = $('div[data-comp-prices]').attr('data-comp-solotodo-enabled')

  if (solotodoPresent == 'true') {
    var productId = $('div[data-comp-prices]').attr('data-comp-product-id')
    var compDataContainer = $('#comp-data')

    if (compDataContainer.length && productId !== '') {
      $(window).one('load', function () {
        if (compDataContainer.isInViewport()) {
          Spree.fetchCompData(productId, compDataContainer)
        }
      })
    }
  }
})
