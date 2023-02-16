$(document).ready(function () {
  $('.enviame-carrier-select').change(function () {
    var carrier_id = this.options[this.selectedIndex].value;
    var shipment_number = this.getAttribute('data-shipment-number');
    if(carrier_id == 'moova'){
      $('#' + shipment_number + '_package-size-show').removeClass("is-hidden");
    }
    else{
      $('#' + shipment_number + '_package-size-show').addClass("is-hidden");
    }

    if(carrier_id.length){
      getCarrierServices(carrier_id, shipment_number)
    }else{
      document.getElementById(shipment_number + '-service-select').options.length = 0;
    }
  })

  $('.eniame-create-delivery').click(function () {
    var shipment_number = this.getAttribute('data-shipment-number');
    var carrier_id = $('#' + shipment_number + '-carrier-select').children("option:selected"). val();
    var service_id = $('#' + shipment_number + '-service-select').children("option:selected"). val();
    if(service_id == '' || carrier_id == ''){
      alert('Please select carrier and service!');
      return false;
    }
    var n_packages = $('#' + shipment_number + '-n-packages').val();
    var package_size = $('#' + shipment_number + '-package-size-select').val();

    createDelivery(shipment_number, carrier_id, service_id, n_packages, package_size);
    return false;
  })

  $('.delete-shipping-label').on('click', function(){
    let shipment_label = this.getAttribute('data-shipment-label');
    if (confirm('Are you sure? You want to delete this shipping label?')) {
      removeShippingLabel(shipment_label);
    }
  })

  $('a.edit-tracking-carrier').on('click', function(event){ toogleEdit(event, 'tracking-carrier'); })
  $('a.cancel-tracking-carrier').on('click', function(event){ toogleEdit(event, 'tracking-carrier'); })

  // handle reference_number edit click
  $('a.edit-reference-number').on('click', function(event){ toogleEdit(event, 'reference-number'); })
  $('a.cancel-reference-number').on('click', function(event){ toogleEdit(event, 'reference-number'); })

  // handle shipment state edit click
  $('a.edit-shipment-state').on('click', function(event){ toogleEdit(event, 'shipment-state'); })
  $('a.cancel-shipment-state').on('click', function(event){ toogleEdit(event, 'shipment-state'); })

  // handle shipment reference number
  $('[data-hook=admin_shipment_form] a.save-reference-number').on('click', function (event) {
    event.preventDefault()

    var link = $(this)
    var shipmentNumber = link.data('shipment-number')
    var referenceNumber = link.parents('tbody').find('input#reference_number').val();
    var url = Spree.url(Spree.routes.shipments_api + '/' + shipmentNumber + '.json')

    $.ajax({
      type: 'PUT',
      url: url,
      data: {
        shipment: {
          reference_number: referenceNumber
        },
        token: Spree.api_key
      }
    }).done(function (data) {
      link.parents('tbody').find('tr.edit-reference-number').toggle()

      var show = link.parents('tbody').find('tr.show-reference-number')
      show.toggle()

      if (data.reference_number) {
        show.find('.reference-value').html($('<strong>').html(Spree.translations.reference_number + ': '+ data.reference_number))
      } else {
        show.find('.reference-value').html(Spree.translations.no_reference_number_present)
      }
    })
  })

  updateShipmentState();
})

function toogleEdit(event, objClass) {
  event.preventDefault()

  var link = $(event.target)
  link.parents('tbody').find('tr.edit-'+objClass).toggle()
  link.parents('tbody').find('tr.show-'+objClass).toggle()
}

function getCarrierServices(carrier_id, shipment_number) {
  $.ajax({
    type: 'GET',
    url: '/admin/orders/get_services',
    data: {
      carrier_id: carrier_id,
      shipment_number: shipment_number
    }
  }).done(function (data) {
    var options = [];
    $.each(data['data'], function(key, value)
    {
      options.push('<option value="'+ value[0] +'" selected>'+ value[1] +'</option>');
    });
    var service_select = $('#' + data['shipment_number'] + '-service-select');
    service_select.html(options.join(''));
    service_select.val($('#' + data['shipment_number'] + '-service-select option:eq(0)').val()).trigger('change');
  }).fail(function (msg) {
    alert(msg.responseJSON.message || msg.responseJSON.exception)
  })
}

function createDelivery(shipment_number, carrier_id, service_id, n_packages, package_size) {
  $.ajax({
    type: 'POST',
    url: '/admin/orders/create_shipment_delivery',
    data: {
      authenticity_token: AUTH_TOKEN,
      shipment_number: shipment_number,
      carrier_id: carrier_id,
      service_id: service_id,
      n_packages: n_packages,
      package_size: package_size
    }
  }).done(function (data) {
    if(data['success']){
      window.location.reload();
    }else{
      alert(data['message']);
    }
  }).fail(function (msg) {
    alert(msg.responseJSON.message || msg.responseJSON.exception)
  })
}

function removeShippingLabel(shipment_label) {
  $.ajax({
    type: 'DELETE',
    url: '/admin/orders/remove_shipping_label',
    data: { authenticity_token: AUTH_TOKEN, shipment_label_id: shipment_label }
  }).done(function(data) {
    if(data['success']){
      window.location.reload();
    } else {
      alert(data['message']);
    }
  }).fail(function (msg) {
    alert(msg.responseJSON.message || msg.responseJSON.exception)
  })
}

function updateShipmentState(){
  $('[data-hook=admin_shipment_form] a.save-shipment-state').on('click', function (event) {
    event.preventDefault()
    var link = $(this)
    var shipmentNumber = link.data('shipment-number')
    var shipmentState = $('#' + shipmentNumber + '_shipment_state').val();
    var url = Spree.url(Spree.routes.shipments_api + '/' + shipmentNumber + '/update_state.json')
    $.ajax({
      type: 'PUT',
      url: url,
      data: {
        shipment: {
          state: shipmentState
        },
        token: Spree.api_key
      }
    }).done(function (data) {
      window.location.reload();
    }).fail(function (msg) {
      alert(msg.responseJSON.message || msg.responseJSON.exception)
    })
  })
}
