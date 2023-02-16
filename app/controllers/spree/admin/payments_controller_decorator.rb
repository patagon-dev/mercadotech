module Spree
  module Admin
    module PaymentsControllerDecorator
      def create
        invoke_callbacks(:create, :before)

        begin
          if @payment_method.store_credit?
            Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order, vendor_id: params[:payment][:vendor_id])
            payments = @order.payments.store_credits.valid
          else
            @payment ||= @order.payments.build(object_params)
            if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
              @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
            end
            @payment.save
            payments = [@payment]
          end

          if payments && (saved_payments = payments.select(&:persisted?)).any?
            invoke_callbacks(:create, :after)

            # Transition order as far as it will go.
            while @order.next; end
            # If "@order.next" didn't trigger payment processing already (e.g. if the order was
            # already complete) then trigger it manually now

            saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }
            flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
            redirect_to admin_order_payments_path(@order)
          else
            @payment ||= @order.payments.build(object_params)
            invoke_callbacks(:create, :fails)
            flash[:error] = Spree.t(:payment_could_not_be_created)
            render :new
          end
        rescue Spree::Core::GatewayError => e
          @payment.invalidate! if @payment.amount < 0 && @order.payment_state == 'credit_owed' && check_payment_method
          invoke_callbacks(:create, :fails)
          flash[:error] = e.message.to_s
          redirect_to new_admin_order_payment_path(@order)
        end
      end

      def show
        @refund_history = Spree::RefundHistory.find_by(reference_number: @payment.number)
      end

      def make_refund
        payment = Spree::Payment.find_by(number: params[:id])
        return false unless payment

        response = Banks::RefundMoney.new(payment.number, payment.amount.abs, payment.vendor_id).execute

        if response[:success]
          payment.update_column(:amount_refunded, true)
          state = payment.amount > 0 ? 'refunded' : 'complete'
          payment.send(state)
          flash[:success] = Spree.t(:refund_successfully, scope: :bank_account)
        else
          flash[:error] = response[:message]
        end
        redirect_to admin_order_payments_path(@order)
      end

      private

      def check_payment_method
        Spree::PaymentMethod::REFUND_PAYMENT_METHODS.include? @payment.payment_method.class
      end
    end
  end
end

::Spree::Admin::PaymentsController.prepend Spree::Admin::PaymentsControllerDecorator
