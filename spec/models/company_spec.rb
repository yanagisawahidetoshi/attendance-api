# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'バリデーションエラーがないこと' do
    expect(build(:company)).to be_valid
  end

  it '名前が無ければ無効であること' do
    company = build(:company, name: nil)
    company.valid?
    expect(company.errors[:name]).to include("を入力してください")
  end

  it '名前が33文字以上なら無効であること' do
    company = build(:company, name: 'a' * 33)
    company.valid?
    expect(company.errors[:name]).to include('は32文字以内で入力してください')
  end

  it '名前が32文字なら有効であること' do
    company = build(:company, name: 'a' * 32)
    company.valid?
    expect(build(:company)).to be_valid
  end

  it '郵便番号が9文字なら無効であること' do
    company = build(:company, zip: '553-00023')
    company.valid?
    expect(company.errors[:zip]).to include('は8文字以内で入力してください')
  end

  it '郵便番号のハイフンが２こあれば無効であること' do
    company = build(:company, zip: '553-000-3')
    company.valid?
    expect(company.errors[:zip]).to include('は不正な値です')
  end
  
  it '郵便番号のハイフンがなければ有効であること' do
    company = build(:company, zip: '5530002')
    company.valid?
    expect(build(:company)).to be_valid
  end
  
  it '電話番号が14文字なら無効であること' do
    company = build(:company, tel: '090-4295-61856')
    company.valid?
    expect(company.errors[:tel]).to include('は13文字以内で入力してください')
  end
  
  it '電話番号のハイフンが２個続きであれば無効であること' do
    company = build(:company, tel: '090-4295--6185')
    company.valid?
    expect(company.errors[:tel]).to include('は不正な値です')
  end

  it '電話番号のハイフンがない場合は有効であること' do
    company = build(:company, tel: '09042956185')
    company.valid?
    expect(build(:company)).to be_valid
  end
  
  it '住所が65文字なら無効であること' do
    company = build(:company, address: 'a' * 65)
    company.valid?
    expect(company.errors[:address]).to include('は64文字以内で入力してください')
  end

  it '住所が64文字なら有効であること' do
    company = build(:company, address: 'a' * 64)
    company.valid?
    expect(build(:company)).to be_valid
  end
end
