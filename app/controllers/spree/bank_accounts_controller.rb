module Spree
  class BankAccountsController < Spree::StoreController
    load_resource class: Spree::BankAccount

    def create
      @bank_account = try_spree_current_user.bank_accounts.build(bank_account_params)
      if @bank_account.save
        flash[:notice] = Spree.t(:successfully_created, scope: :bank_account)
        redirect_to spree.account_path
      else
        render action: :new
      end
    end

    def edit
      session['spree_user_return_to'] = request.env['HTTP_REFERER']
    end

    def new
      @bank_account = Spree::BankAccount.new
    end

    def update
      if @bank_account.update(bank_account_params)
        flash[:notice] = Spree.t(:successfully_updated, scope: :bank_account)
        redirect_back_or_default(account_path)
      else
        render :edit
      end
    end

    def destroy
      flash[:notice] = if @bank_account.destroy
                         Spree.t(:successfully_destroyed, scope: :bank_account)
                       else
                         @bank_account.errors.full_messages.join(', ')
                       end
      redirect_to(account_path)
    end

    private

    def bank_account_params
      params.require(:bank_account).permit!
    end
  end
end
