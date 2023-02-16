class Spree::Admin::ListsController < Spree::Admin::ResourceController
  before_action :find_list, only: [:sync_subscribers]

  def index
    @lists = Spree::List.all
  end

  def new
    @list = Spree::List.new
  end

  def create
    @list = Spree::List.new(list_params)

    if @list.save
      flash[:success] = Spree.t(:successfully_created, scope: :list)
      redirect_to admin_lists_path
    else
      flash[:error] = @list.errors.full_messages.join(', ')
      render action: :new
    end
  end

  def sync_subscribers
    if @list
      api_response = Sendy::Client.new.active_subscriber_count(@list.key)
      response, message = api_response.to_i == 0 ? [:error, api_response] : [:success, Spree.t(:successfully_synchronize)]

      @list.update_column(:subscribers_count, api_response) if api_response
    else
      response = :error
      message = Spree.t(:list_id_not_present, scope: :list)
    end
    flash[response] = message
    redirect_to admin_lists_path
  end

  private

  def find_list
    @list = Spree::List.find_by(id: params[:id])
  end

  def list_params
    params.require(:list).permit!
  end
end
