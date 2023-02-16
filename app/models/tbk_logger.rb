class TbkLogger
  def initialize(payment:, order:)
    @payment_id = payment.try(:id) if payment.present?
    @order_number = order.try(:number) if order.present?
  end

  def logger
    Logger.new(TbkLogger.path)
  end

  def self.path
    if Rails.env.test?
      "#{Rails.root}/log/webpay_ws_mall_test.log"
    else
      "#{Rails.root}/log/webpay_ws_mall.log"
    end
  end

  def log_info(action:, content:)
    exec_log_info(id: "[#{@order_number}:#{@payment_id}]", action: I18n.t(action), content: content)
  end

  def log_error(action:, content:)
    exec_log_error(id: "[#{@order_number}:#{@payment_id}]", action: I18n.t(action), content: content)
  end

  def exec_log_info(id:, action:, content:)
    logger.info("#{id} #{action} #{content}")
  end

  def exec_log_error(id:, action:, content:)
    logger.error("#{id} #{action} #{content}")
  end
end
