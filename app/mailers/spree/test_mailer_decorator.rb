module Spree::TestMailerDecorator
  def test_email(email)
    @current_store = Spree::Store.current
    subject = "#{Spree::Store.current.name} #{Spree.t('test_mailer.test_email.subject')}"
    mail(to: email, from: from_address, subject: subject)
  end
  Spree::TestMailer.prepend Spree::TestMailerDecorator
end
