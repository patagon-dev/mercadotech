function updateAddressFields(){
  if ($('#checkout_form_address').length) {

    let invoiceSelectTag = document.getElementsByClassName('invoice-select')[0];
    invoiceSelectTag.addEventListener('change', function(){
      onChangeInvoiceOptions(invoiceSelectTag, false);
    })

    onChangeInvoiceOptions(invoiceSelectTag, true); // on Load
  }
}

function onChangeInvoiceOptions(selectTag, onLoad){
  let selectedVal = selectTag.options[selectTag.selectedIndex].value;
  let companyRut = document.getElementById('bcompany_rut');
  let countySelect = document.getElementById('bcounty');
  const fields = ['bfull_name', 'bphone'];

  if (selectedVal == '39') {
    $("#bcompany, #bcompany_business").each(function( index ) {
      let inputField = this.querySelector('input');
      inputField.setAttribute('disabled', 'disabled');
      inputField.removeAttribute('required');
      this.parentElement.classList.add('d-none');
    });

    if (companyRut != null && companyRut) {
      for(i=(fields.length-1); i >= 0; i--){
        element = document.getElementById(fields[i])
        companyRut.parentElement.insertAdjacentHTML('afterend', element.parentElement.outerHTML)
        element.parentElement.remove()
      }
    }
  }
  else {
    if (!onLoad) {

      $("#bcompany, #bcompany_business").each(function( index ) {
        let inputField = this.querySelector('input');
        inputField.removeAttribute('disabled');
        inputField.setAttribute('required', 'required');
        this.parentElement.classList.remove('d-none');
      });

      for(i=(fields.length-1); i >= 0; i--){
        element = document.getElementById(fields[i])
        countySelect.insertAdjacentHTML('afterend', element.parentElement.outerHTML)
        element.parentElement.remove()
      }
    }
  }
}

Spree.ready(function ($) {
  updateAddressFields();
})
