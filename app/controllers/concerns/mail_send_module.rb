# frozen_string_literal: true

require 'sendgrid-ruby'
include SendGrid

module MailSendModule
  extend ActiveSupport::Concern

  def send_mail(to:, subject:, body:)
    return unless Rails.env.production?
    email_from = Email.new(email: 'yanagisawa@ultrasevenstar.com')
    email_to = Email.new(email: to)
    content = Content.new(type: 'text/plain', value: body)
    mail = Mail.new(email_from, subject, email_to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
