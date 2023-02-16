(function ($) {
  $(document).ready(function () {
    if ($("input[name='order[payments_attributes][][payment_method_id]']:radio").length > 0) {
      if($('.purchased_order_attach').length > 0){
        $('#store-credit-btn').click(function(){
          $('.purchased_order_attach').prop('required', true)
        })
      }

      $("input[name='order[payments_attributes][][payment_method_id]']:radio").change(function(){
       $('.purchased_order_attach').prop('required', false)
      })
    }
  })
})(jQuery)
