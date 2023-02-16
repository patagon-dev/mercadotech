class Spree::Admin::BankAccountsController < Spree::Admin::ResourceController
  before_action :load_order

  def index
    @bank_accounts = @order.user ? @order.user.bank_accounts : Spree::BankAccount.guest_user_account(@order.email)
  end

  def new
    @bank_account = Spree::BankAccount.new(user_id: @order.user_id)
  end

  def create
    @bank_account = @order.user ? @order.user.bank_accounts.build(bank_account_params) : Spree::BankAccount.new(bank_account_params.merge(is_guest_user: true, guest_user_email: @order.email))
    if @bank_account.save
      flash[:notice] = Spree.t(:successfully_created, scope: :bank_account)
      redirect_to spree.admin_order_bank_accounts_path(@order)
    else
      flash[:error] = @bank_account.errors.full_messages.join(', ')
      render action: :new
    end
  end

  private

  def load_order
    @order = Spree::Order.find_by_number(params[:order_id])
  end

  def bank_account_params
    params.require(:bank_account).permit!
  end
end
