document.addEventListener('turbolinks:load', function () {
  $(document).ready(function () {
    var formFields = $("[data-hook='return_authorization_form_fields']")

    function checkAddItemBox () {
      $(this).closest('tr').find('input.add-item').attr('checked', 'checked')
      updateSuggestedAmount()
    }

    function updateSuggestedAmount () {
      var totalPretaxRefund = 0
      var checkedItems = formFields.find('input.add-item:checked')
      $.each(checkedItems, function (i, checkbox) {
        var returnItemRow = $(checkbox).parents('tr')
        var returnQuantity = parseInt(returnItemRow.find('.refund-quantity-input').val(), 10)
        var purchasedQuantity = parseInt(returnItemRow.find('.purchased-quantity').text(), 10)
        var amount = (returnQuantity / purchasedQuantity) * parseFloat(returnItemRow.find('.charged-amount').data('chargedAmount'))
        returnItemRow.find('.refund-amount-input').val(amount.toFixed())
        totalPretaxRefund += amount
      })

      var displayTotal = isNaN(totalPretaxRefund) ? '' : totalPretaxRefund.toFixed()
      formFields.find('span#total_pre_tax_refund').html(displayTotal)
    }

    function tooglePickupOptions() {
      let checkBox = document.getElementById('return_authorization_request_pickup')
      if (checkBox) {
        checkBox.addEventListener('change', function(){
          let rmaFields = document.getElementsByClassName('rma_shipping_label_contant')[0];
          if (this.checked) rmaFields.classList.remove('d-none')
          else rmaFields.classList.add('d-none')
        })
      }
    }

    if (formFields.length > 0) {
      updateSuggestedAmount()

      formFields.find('input.add-item').on('change', updateSuggestedAmount)
      formFields.find('.refund-amount-input').on('keyup', updateSuggestedAmount)
      formFields.find('.refund-quantity-input').on('keyup mouseup', updateSuggestedAmount)
      formFields.find('input, select').not('.add-item').on('change', checkAddItemBox)
      formFields.find('.return_pickup').on('keyup mouseup', tooglePickupOptions)
    }
  })
})
