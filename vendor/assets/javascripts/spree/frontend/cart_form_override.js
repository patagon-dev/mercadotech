function CartForm($, $cartForm) {
  this.constructor = function() {
    this.initialize()
    this.bindEventHandlers()
  }

  this.initialize = function() {
    this.selectedOptionValueIds = []
    this.variants = JSON.parse($cartForm.attr('data-variants'))
    this.withOptionValues = Boolean($cartForm.find(OPTION_VALUE_SELECTOR).length)

    this.$addToCart = $cartForm.find(ADD_TO_CART_SELECTOR)
    this.$price = $cartForm.find('.price.selling')
    this.$variantIdInput = $cartForm.find(VARIANT_ID_SELECTOR)
    this.$variantSku = $cartForm.find('.variant-sku')
    this.$variantName = $('.product-details-title')
    this.$variantStock = $cartForm.find('.variant-stock')
    this.initializeForm()
  }

  this.initializeForm = function() {
    if (this.withOptionValues) {
      var $optionValue = this.firstCheckedOptionValue()
      this.applyCheckedOptionValue($optionValue, true)
    } else {
      this.updateAddToCart()
      this.triggerVariantImages()
    }
  }

  this.bindEventHandlers = function() {
    $cartForm.on('click', OPTION_VALUE_SELECTOR, this.handleOptionValueClick)
  }

  this.handleOptionValueClick = function(event) {
    this.applyCheckedOptionValue($(event.currentTarget))
    event.currentTarget.blur()
  }.bind(this)

  this.applyCheckedOptionValue = function($optionValue, initialUpdate) {
    this.saveCheckedOptionValue($optionValue)
    this.showAvailableVariants()
    this.updateAddToCart()
    // we don't want to remove availability status on initial page load
    if (!initialUpdate) this.updateVariantAvailability()
    this.updateVariantPrice()
    this.updateVariantNameAndSku()
    this.updateVariantId()
    if (this.shouldTriggerVariantImage($optionValue)) {
      this.triggerVariantImages()
    }
  }

  this.saveCheckedOptionValue = function($optionValue) {
    var optionTypeIndex = $optionValue.data('option-type-index')

    this.selectedOptionValueIds.splice(
      optionTypeIndex,
      this.selectedOptionValueIds.length,
      parseInt($optionValue.val())
    )
  }

  this.showAvailableVariants = function() {
    var availableOptionValueIds = this.availableOptionValueIds()
    var selectedOptionValueIdsCount = this.selectedOptionValueIds.length

    this.optionTypes().each(function(index, optionType) {
      if (index < selectedOptionValueIdsCount) return

      $(optionType)
        .find(OPTION_VALUE_SELECTOR)
        .each(function(_index, ov) {
          var $ov = $(ov)
          var id = parseInt($ov.val())

          $ov.prop('checked', false)
          $ov.prop('disabled', !availableOptionValueIds.includes(id))
        })
    })
  }

  this.optionTypes = function() {
    return $cartForm.find('.product-variants-variant')
  }

  this.availableOptionValueIds = function() {
    var selectedOptionValueIds = this.selectedOptionValueIds

    return this.variants.reduce(function(acc, variant) {
      var optionValues = variant.option_values.map(function(ov) {
        return ov.id
      })

      var isPossibleVariantFound = selectedOptionValueIds.every(function(ov) {
        return optionValues.includes(ov)
      })

      if (isPossibleVariantFound) {
        return acc.concat(optionValues)
      }

      return acc
    }, [])
  }

  this.firstCheckedOptionValue = function() {
    return $cartForm.find(OPTION_VALUE_SELECTOR + '[data-option-type-index=0]' + ':checked')
  }

  this.shouldTriggerVariantImage = function($optionValue) {
    return $optionValue.data('is-color') || !this.firstCheckedOptionValue().data('is-color')
  }

  this.triggerVariantImages = function() {
    var checkedVariantId
    var variant = this.selectedVariant()

    if (variant) {
      checkedVariantId = variant.id
    } else {
      checkedVariantId = this.firstCheckedOptionValue().data('variant-id')
    }

    // Wait for listeners to attach.
    setTimeout(function() {
      $cartForm.trigger({
        type: 'variant_id_change',
        triggerId: $cartForm.attr('data-variant-change-trigger-identifier'),
        variantId: checkedVariantId + ''
      })
    })
  }

  this.selectedVariant = function() {
    var self = this

    if (!this.withOptionValues) {
      return this.variants.find(function(variant) {
        return variant.id === parseInt(self.$variantIdInput.val())
      })
    }

    if (this.variants.length === 1 && this.variants[0].is_master) {
      return this.variants[0]
    }

    return this.variants.find(function(variant) {
      var optionValueIds = variant.option_values.map(function(ov) {
        return ov.id
      })

      return self.areArraysEqual(optionValueIds, self.selectedOptionValueIds)
    })
  }

  this.areArraysEqual = function(array1, array2) {
    return this.sortArray(array1).join(',') === this.sortArray(array2).join(',')
  }

  this.sortArray = function(array) {
    return array.concat().sort(function(a, b) {
      if (a < b) return -1
      if (a > b) return 1

      return 0
    })
  }

  this.updateAddToCart = function() {
    var variant = this.selectedVariant()

    this.$addToCart.prop('disabled', variant ? !variant.purchasable : true)
  }

  this.availabilityMessage = function(variant) {
    if (!variant.is_product_available_in_currency) {
      return $(AVAILABILITY_TEMPLATES.notAvailableInCurrency).html()
    }

    if (variant.in_stock) {
      return $(AVAILABILITY_TEMPLATES.inStock).html()
    }

    if (variant.backorderable) {
      return $(AVAILABILITY_TEMPLATES.backorderable).html()
    }

    return $(AVAILABILITY_TEMPLATES.outOfStock).html()
  }

  this.updateVariantAvailability = function() {
    var variant = this.selectedVariant()

    if (!variant) {
      return $cartForm
        .find('.add-to-cart-form-general-availability .add-to-cart-form-general-availability-value')
        .html('')
    }

    return $cartForm
      .find('.add-to-cart-form-general-availability .add-to-cart-form-general-availability-value')
      .html(this.availabilityMessage(variant))
  }

  this.updateVariantPrice = function() {
    var variant = this.selectedVariant()

    if (!variant) return

    this.$price.html(variant.display_price)
  }

  this.updateVariantId = function() {
    var variant = this.selectedVariant()
    var variantId = (variant && variant.id) || ''

    this.$variantIdInput.val(variantId)
  }

  this.updateVariantNameAndSku = function() {
    var variant = this.selectedVariant()
    var variantName = (variant && variant.name) || ''
    var variantSku = (variant && variant.sku) || ''
    var stock_data = (variant && variant.stock_data) || ''
    var stock_in_hand = (variant && stock_data[0]["count_on_hand"]) || ''
    if (!variant) return

    this.$variantSku.html('Sku:'+variantSku)
    this.$variantName.html(variantName)
    this.$variantStock.html(`En stock (${stock_in_hand})`)

  this.constructor()
}
