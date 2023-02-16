module Spree
  module AddressesControllerDecorator
    def update
      if @address.editable?
        if @address.update(address_params)
          flash[:notice] = Spree.t(:successfully_updated, scope: :address_book)
          redirect_back_or_default(addresses_path)
        else
          render :edit
        end
      else
        new_address = @address.clone
        new_address.attributes = address_params
        new_address.user_id = spree_current_user.id
        @address.update_attribute(:deleted_at, Time.current)
        if new_address.save
          flash[:notice] = Spree.t(:successfully_updated, scope: :address_book)
          redirect_back_or_default(addresses_path)
        else
          render :edit
        end
      end
    end
  end
end

::Spree::AddressesController.prepend Spree::AddressesControllerDecorator
