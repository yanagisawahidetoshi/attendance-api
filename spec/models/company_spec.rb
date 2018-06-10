# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'バリデーションエラーがないこと' do
    expect(build(:company)).to be_valid
  end

  it '名前が無ければ無効であること' do
    company = build(:company, name: nil)
    company.valid?
    expect(company.errors[:name]).to include("can't be blank")
  end

  it '名前が33文字以上なら無効であること' do
    company = build(:company, name: 'sbMlrfWR7j9SxIodGEalQqsg262SQvW9lqDzWCcc2azGCcCPebIwZE7C5iPB98qJezLFlI7W1BX65vQFdkIa0p3Bmco2SD5COeKxJRqtwWnoTiKe7Jkhgflxys1M9PvLsesuhdg3pIBOyFIY3CitrUYAfXwUGyZJKQ9giHHiuvtsRA79aslrTWSWiDefYnqNtrLyS1Zfhhpf6cKN8WUSyh2l7RIlgqgn0iASgQsjrP3BAxSSmts7jocJEv3ViOxcBbb7ccUY9AhWmcpcMJN2LvHSglpZRD4ECqknWGpZiMZqWux3EM1b7Pcrwn7DzShDU0s0HWGvFL')
    company.valid?
    expect(company.errors[:name]).to include('is too long (maximum is 32 characters)')
  end

  it '名前が32文字なら有効であること' do
    company = build(:company, name: 'bMlrfWR7j9SxIodGEalQqsg262SQvW9lqDzWCcc2azGCcCPebIwZE7C5iPB98qJezLFlI7W1BX65vQFdkIa0p3Bmco2SD5COeKxJRqtwWnoTiKe7Jkhgflxys1M9PvLsesuhdg3pIBOyFIY3CitrUYAfXwUGyZJKQ9giHHiuvtsRA79aslrTWSWiDefYnqNtrLyS1Zfhhpf6cKN8WUSyh2l7RIlgqgn0iASgQsjrP3BAxSSmts7jocJEv3ViOxcBbb7ccUY9AhWmcpcMJN2LvHSglpZRD4ECqknWGpZiMZqWux3EM1b7Pcrwn7DzShDU0s0HWGvFL')
    company.valid?
    expect(build(:company)).to be_valid
  end

  it '郵便番号が9文字なら無効であること' do
    company = build(:company, zip: '553-00023')
    company.valid?
    expect(company.errors[:zip]).to include('is too long (maximum is 8 characters)')
  end

  it '電話番号が14文字なら無効であること' do
    company = build(:company, tel: '090-4295-61856')
    company.valid?
    expect(company.errors[:tel]).to include('is too long (maximum is 13 characters)')
  end

  it '住所が65文字なら無効であること' do
    company = build(:company, address: 'EPaXx25VwzLXMTSmrwERG9h-ficJEgVfUXbtHZMi_PnYEjwBT4Wx7R_EEtMPEEpzH8Rzz4jytVzFaaeFVMAcAWWDwrVM5pd5ZF8sPEeSdf64QG4z4cCpZUDYbe5rZ8Y9dXs_DFMjV5H4xM3-kMgjiSSB4ca-YSUYuueFLFtA5nj9zWYA7eSE8XrEd2p5HNJgTVg9EbphdAPb3-7J3s6p3EGHj7tURDWBNxg3hxnpVKssumm7EzGrmUhD7Ua3cjVQtnBs-_RHyAdGmegB_szR3rVtE_K74LMu7_Knk9P7JAJtA6c25RHTWN73462Qwh3mxyb5w
')
    company.valid?
    expect(company.errors[:address]).to include('is too long (maximum is 64 characters)')
  end

  it '住所が64文字なら有効であること' do
    company = build(:company, address: 'PaXx25VwzLXMTSmrwERG9h-ficJEgVfUXbtHZMi_PnYEjwBT4Wx7R_EEtMPEEpzH8Rzz4jytVzFaaeFVMAcAWWDwrVM5pd5ZF8sPEeSdf64QG4z4cCpZUDYbe5rZ8Y9dXs_DFMjV5H4xM3-kMgjiSSB4ca-YSUYuueFLFtA5nj9zWYA7eSE8XrEd2p5HNJgTVg9EbphdAPb3-7J3s6p3EGHj7tURDWBNxg3hxnpVKssumm7EzGrmUhD7Ua3cjVQtnBs-_RHyAdGmegB_szR3rVtE_K74LMu7_Knk9P7JAJtA6c25RHTWN73462Qwh3mxyb5w
')
    company.valid?
    expect(build(:company)).to be_valid
  end
end
