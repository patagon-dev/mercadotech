/* global toggleItemEdit, order_number */
$(function () {
  // handle save click
  $('a.save-line-item-custom').click(function () {
    var save = $(this)
    var lineItemId = save.data('line-item-id')
    var quantity = parseInt(save.parents('tr').find('input.line_item_quantity').val())
    var customPrice = parseInt(save.parents('tr').find('input.line_item_price').val())
    toggleItemEdit()
    adjustLineItem(lineItemId, quantity, customPrice)
  })
})

function adjustLineItem (lineItemId, quantity, customPrice) {
  $.ajax({
    type: 'PUT',
    url: Spree.url(lineItemURL(lineItemId)),
    data: {
      line_item: {
        quantity: quantity,
        custom_price: customPrice
      },
      token: Spree.api_key
    }
  }).done(function () {
    window.Spree.advanceOrder()
  })
}

function toggleLineItemEdit () {
  var link = $(this)
  var parent = link.parent()
  var tr = link.parents('tr')
  parent.find('a.edit-line-item').toggle()
  parent.find('a.cancel-line-item').toggle()
  parent.find('a.save-line-item-custom').toggle()
  parent.find('a.delete-line-item').toggle()
  tr.find('td.line-item-qty-show').toggle()
  tr.find('td.line-item-qty-edit').toggle()
  tr.find('td.line-item-price-show').toggle()
  tr.find('td.line-item-price-edit').toggle()
}
