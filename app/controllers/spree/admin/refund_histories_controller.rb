class Spree::Admin::RefundHistoriesController < Spree::Admin::ResourceController
  before_action :find_refund_history, only: [:update]

  def update
    if params[:refund_state].present?
      response, message = @refund_history.send(params[:refund_state]) ? [:sucess, Spree.t(:updated_successfully, scope: :refund )] : [:error, Spree.t(:invalid_state, scope: :refund)]
      flash[response] = message
    end

    redirect_back(fallback_location: '/admin')
  end

  private

  def find_refund_history
    @refund_history = Spree::RefundHistory.find_by(id: params[:id])
  end
end