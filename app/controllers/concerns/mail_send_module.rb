require 'sendgrid-ruby'
include SendGrid

module MailSendModule
  extend ActiveSupport::Concern

  def send_mai(to:, mail_type:)
    email_from = Email.new(email: 'test@example.com')
    email_to = Email.new(email: to)
    subject = 'Sending with SendGrid is Fun'
    content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
    mail = Mail.new(email_from, subject, email_to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
  end
end