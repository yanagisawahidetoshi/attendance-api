# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'バリデーションエラーがないこと' do
    expect(build(:user)).to be_valid
  end

  it 'メールが無ければ無効であること' do
    user = build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include("を入力してください")
  end

  it '名前が無ければ無効であること' do
    user = build(:user, name: nil)
    user.valid?
    expect(user.errors[:name]).to include("を入力してください")
  end

  it '権限が無ければ無効であること' do
    user = build(:user, authority: nil)
    user.valid?
    expect(user.errors[:authority]).to include("を入力してください")
  end

  it 'パスワードが無ければ無効であること' do
    user = build(:user, password: nil)
    user.valid?
    expect(user.errors[:password]).to include("を入力してください")
  end


end
