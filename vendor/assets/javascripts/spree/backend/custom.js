$(document).ready(function(){

  // Bulk actions on orders
  Spree.bulkActionOnOrders = function(){
    let selectAllCheckBox = document.getElementById('select-all-orders')

    if (selectAllCheckBox) {
      selectAllCheckBox.addEventListener('click', function(event){
        let orderIds = document.getElementsByClassName('order_ids')

        for (i=0; i < orderIds.length; i++) {
          orderIds[i].checked = event.target.checked
        }
      })
    }
  }

  // Generate pickup list
  Spree.generatePickupList = function(){
    let pickupListButton = document.getElementById('admin_new_pickup_list');
    let orderRows = document.querySelectorAll('.order_ids')

    if (pickupListButton && orderRows.length > 0) {
      pickupListButton.addEventListener('click', function(event) {
        event.preventDefault();
        Spree.submitFormWithOrderIds('pickup-list-form', 'pickup_list')
      }, false);
    }
  }

  // Generate purchase list
  Spree.generatePurchaseList = function(){
    let purchaseListButton = document.getElementById('admin_new_purchase_list');
    let orderRows = document.querySelectorAll('.order_ids')

    if (purchaseListButton && orderRows.length > 0) {
      purchaseListButton.addEventListener('click', function(event) {
        event.preventDefault();
        Spree.submitFormWithOrderIds('purchase-list-form', 'purchase_list')
      }, false);
    }
  }

  Spree.submitFormWithOrderIds = function(formId, formScope){
    let selectAllCheckBox = document.getElementById('select-all-orders')
    let orderRows = document.querySelectorAll('.order_ids:checked')
    let records = [];

    if (!(selectAllCheckBox || orderRows)) return false;

    if (selectAllCheckBox && selectAllCheckBox.checked) {
      records.push('all');
    }
    else {
      for (i=0; i < orderRows.length; i++) {
        records.push(orderRows[i].value)
      }
    }

    var hiddenOrderField = document.getElementById(formScope+'_order_ids')
    hiddenOrderField.setAttribute('value', records);

    // Submiting Form
    $('#'+formId).submit();
  }

  // Toggle on invoice select tag
  Spree.onSelectOptions = function(elementId, divContainer, divContainer2, defaultValue){
    let selectTag = document.getElementById(elementId);
    if (selectTag && selectTag != null) {
      selectTag.addEventListener('change', function(){
        let optValue = this.options[this.selectedIndex].value;
        let container = document.getElementsByClassName(divContainer)[0];
        let container2 = document.getElementsByClassName(divContainer2)[0];

        if (optValue == defaultValue) {
          container.classList.remove('d-none');
          if (container2) container2.classList.add('d-none')
        }
        else {
          container.classList.add('d-none');
          if (container2) container2.classList.remove('d-none')
        }
      })
    }
  }

  // handle order reference number save
  Spree.handleOrderReference = function(){
    $('[data-hook=order_edit_form] a.save-reference').on('click', function (event) {
      event.preventDefault()

      var link = $(this)
      var orderNumber = link.data('order-number')
      var referenceNumbers = link.parents('tbody').find('input#reference_order_numbers').val()
      var url = Spree.url(Spree.routes.orders_api + '/' + orderNumber + '/update_reference_numbers.json')

      $.ajax({
        type: 'PUT',
        url: url,
        data: {
          order: {
            reference_order_numbers: referenceNumbers
          },
          token: Spree.api_key
        }
      }).done(function (data) {
        link.parents('tbody').find('tr.edit-tracking').toggle()

        var show = link.parents('tbody').find('tr.show-tracking')
        show.toggle()

        if (data.reference_order_numbers) {
          show.find('.order-reference-value').html($('<strong>').html('Reference Numbers: ')).append(data.reference_order_numbers)
        } else {
          show.find('.order-reference-value').html('No reference order numbers')
        }
      })
    })
  }


  // Set minimum order value for vendor
  Spree.minimumOrderConstraint = function(){
    let minOrderCheckBox = document.getElementsByClassName('set_min_order')[0];
    let minOrderValue = document.getElementById('vendor_minimum_order_value');

    if (minOrderCheckBox) {
      minOrderCheckBox.addEventListener('click', function(){
        if (minOrderCheckBox.checked) minOrderValue.closest('.field').classList.remove('d-none')
        else minOrderValue.closest('.field').classList.add('d-none')
      })
    }
  }

  // Invoice via superfactura
  Spree.updateInvoiceGenerationLink = function(){
    let invoiceBtns = document.getElementsByClassName('generate-invoice');

    if (invoiceBtns.length > 0) {
      for (i=0; i < invoiceBtns.length; i++) {
        invoiceBtns[i].addEventListener('click', function(){
          let baseURL = $(this).attr('data-url');
          let selectedDocumentType = $(this).closest('tr').find('select').children("option:selected").val();

          this.href = baseURL+'&invoice_type='+selectedDocumentType;
          return false;
        })
      }
    }
  }

  // Invoice via manual
  Spree.updateInvoiceForm = function(){
    let forms = document.getElementsByClassName('new_invoice');

    if (forms.length > 0){
      for (i=0; i < forms.length; i++) {
        forms[i].addEventListener('submit', function(){
          let selectedDocumentType = $(this).closest('tr').find('select').children("option:selected").val();
          $('<input>').attr({ type: 'hidden', name: 'invoice_type', value: selectedDocumentType }).appendTo(this);
          return true;
        })
      }
    }
  }

  Spree.toogleMoovaForm = function(){
    let checkBox = document.getElementById('vendor_enable_moova')
    if (checkBox) {
      checkBox.addEventListener('change', function(){
        let moovaFields = document.getElementsByClassName('moova_creds')[0];
        if (this.checked) moovaFields.classList.remove('d-none')
        else moovaFields.classList.add('d-none')
      })
    }
  }

  Spree.toggleMaintenanceModeMessage = function(){
    let maintenanceModeCheckBox = document.getElementById('store_maintenance_mode');
    let maintenanceModeValue = document.getElementById('store_maintenance_message');

    if (maintenanceModeCheckBox) {
      maintenanceModeCheckBox.addEventListener('change', function(){
        if (maintenanceModeCheckBox.checked) maintenanceModeValue.closest('.field').classList.remove('d-none')
        else maintenanceModeValue.closest('.field').classList.add('d-none')
      })
    }
  }

  Spree.refundStateUpdate = function(){
    $('a.refund_history_edit_button').on('click', function(event){
      $('#refund_history_edit_section').removeClass("d-none")
      $('#refund_history_show_section').addClass("d-none")
    })

    $('a.refund_history_cancel_button').on('click', function(event){
      $('#refund_history_show_section').removeClass("d-none")
      $('#refund_history_edit_section').addClass("d-none")
    })
  }

  Spree.toggleBankTansferFields = function(){
    let checkBox = document.getElementById('vendor_enable_bank_transfer')
    if (checkBox) {
      checkBox.addEventListener('change', function(){
        let banktransferFields = document.getElementsByClassName('bank_transfer_fields')[0];
        if (this.checked) banktransferFields.classList.remove('d-none')
        else banktransferFields.classList.add('d-none')
        })
    }
  }

  Spree.tooglePickupOptions = function() {
    let checkBox = document.getElementById('return_authorization_request_pickup')
    if (checkBox) {
      checkBox.addEventListener('change', function(){
        let rmaFields = document.getElementsByClassName('rma_shipping_label_contant')[0];
        if (this.checked) rmaFields.classList.remove('d-none')
        else rmaFields.classList.add('d-none')
      })
    }
  }

  Spree.toggleFooterColumnField = function(){
    let showFooterCheckBox = document.getElementById('page_show_in_footer');
    let footerColumnValue = document.getElementById('footer-column-select');

    if (showFooterCheckBox) {
      showFooterCheckBox.addEventListener('change', function(){
        if (showFooterCheckBox.checked) footerColumnValue.classList.remove('d-none')
        else footerColumnValue.classList.add('d-none')
      })
    }
  }

  var update_county = function (region, done) {
    'use strict';

    var state = $('span#' + region + 'state .select2').select2('val');
    var county_select = $('span#' + region + 'county select.select2');

    $.get('/api/counties?state_id=' + state, function (data) {
      var counties = data.counties;
      if (counties.length > 0) {
        county_select.html('');
        var counties_with_blank = [{
          name: '',
          id: ''
        }].concat(counties);
        $.each(counties_with_blank, function (pos, county) {
          var opt = $(document.createElement('option'))
            .prop('value', state.id)
            .html(county.name);
          county_select.append(opt);
        });
        county_select.prop('disabled', false).show();
        county_select.select2();

      } else {
        county_select.select2('destroy').hide();
      }

      if(done) done();
    });
  };

  Spree.displayReturnItems = function(){
    let stockLocationSelect = document.getElementById('customer_return_stock_location_id');
    let preSelectedVendorId = document.getElementById('input_vendor_id') ? document.getElementById('input_vendor_id').value : null;
    let hiddenVendorField = document.getElementById('input_vendor_id')

    if (stockLocationSelect) {
      selectedItems(preSelectedVendorId, 'onLoadEvent');  // On load

      $('#customer_return_stock_location_id').on('change', function(){  // On change "customer return"
        let vendorId = this.selectedOptions[0].id.split('_')[1]
        hiddenVendorField.setAttribute('value', vendorId)
        $('#total_pre_tax_refund').html('0.00');
        selectedItems(vendorId, 'onChangeEvent');
      })
    }
  }

  Spree.bulkActionOnProduct = function(){
    $("#select-all, #select-all-products").click(function () {
      $(".product-select").prop('checked', $(this).prop('checked'));
    });

    $("#update-shipping-categories-btn, #disable-enable-product-btn").click(function(){
      let product_ids = $.map($('.product-select:checked'), function(t){return t.value; });
      let filter_properties = document.getElementById('current_filter_params')
      let all_products_checkbox = document.getElementById('select-all-products');
      let current_page_products_checkbox = document.getElementById('select-all');

      if(all_products_checkbox.checked && filter_properties.value){
        this.href = this.getAttribute('data-href') + '?filter_params=' + filter_properties.value
      } else if(current_page_products_checkbox.checked && product_ids.length){
        this.href = this.getAttribute('data-href') + '?product_ids=' + product_ids
      } else if(product_ids.length) {
        this.href = this.getAttribute('data-href') + '?product_ids=' + product_ids
      } else {
        alert('Please checked checkbox first.');
        return false;
      }
    })
  }

  function selectedItems(vendorId, eventHandler){
    let returnItems = document.getElementById('vendor_product_list').rows;
    let checkBoxes = document.getElementsByClassName('add-item');

    for (var i=0; i < returnItems.length; i++) {
      returnItems[i].classList.add('d-none');
      $(checkBoxes[i]).prop('checked', false);

      if (returnItems[i].classList.contains('row_item_'+vendorId)) {
        returnItems[i].classList.remove('d-none');
        if (eventHandler == 'onLoadEvent') $(checkBoxes[i]).prop('checked', true);
      }
    }
  }

  // Funcions call on page Load
  Spree.onSelectOptions('vendor_invoice_options', 'superfactura', '', 'superfactura_api');
  Spree.onSelectOptions('vendor_import_options', 'scrapinghub', 'files', 'scrapinghub');
  Spree.bulkActionOnOrders()
  Spree.generatePickupList()
  Spree.generatePurchaseList()
  Spree.handleOrderReference()
  Spree.minimumOrderConstraint()
  Spree.updateInvoiceGenerationLink()
  Spree.updateInvoiceForm()
  Spree.toogleMoovaForm()
  Spree.toggleMaintenanceModeMessage()
  Spree.refundStateUpdate()
  Spree.toggleBankTansferFields()
  Spree.toggleFooterColumnField()
  Spree.tooglePickupOptions()
  Spree.displayReturnItems()
  Spree.bulkActionOnProduct()

  // Load counties on select region
  $("#bstate select").on('change', function(){
    update_county('b')
  })

  $("#sstate select").on('change', function(){
    update_county('s')
  })
});
