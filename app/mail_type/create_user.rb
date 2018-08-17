# frozen_string_literal: true

class CreateUser
  def self.subject
    'ユーザー登録が完了しました'
  end

  def self.body(password)
    body = <<~EOF
      ユーザ登録が完了しました。

      下記の仮パスワードにてログインしパスワードの変更をお願いします。

      #{password}
    EOF
    body
  end
end
