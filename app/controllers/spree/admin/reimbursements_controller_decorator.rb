module Spree
  module Admin
    module ReimbursementsControllerDecorator
      def show
        @refund_history = Spree::RefundHistory.find_by(reference_number: @reimbursement.number)
      end

      def load_simulated_refunds
        load_resource
        @reimbursement_objects = @reimbursement.simulate
      end
    end
  end
end

::Spree::Admin::ReimbursementsController.prepend Spree::Admin::ReimbursementsControllerDecorator
