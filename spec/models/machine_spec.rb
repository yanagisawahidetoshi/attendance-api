require 'rails_helper'

RSpec.describe Machine, type: :model do
  let(:company) { build(:company) }
  context 'バリデーション' do
    it 'バリデーションエラーがないこと' do
      expect(build(:machine, company: company)).to be_valid
    end
    
    it 'companyがnilならエラーになること' do
      machine = build(:machine)
      machine.valid?
      expect(machine.errors[:company]).to include("を入力してください")
    end
    
    it 'mac addressがnilならエラーになること' do
      machine = build(:machine, mac_address: nil)
      machine.valid?
      expect(machine.errors[:mac_address]).to include("を入力してください")
    end
    it 'mac addressの形式が不正な場合エラーになること' do
      machine = build(:machine, company: company, mac_address: "a" * 17)
      machine.valid?
      expect(machine.errors[:mac_address]).to include("は不正な値です")
    end
    it 'mac addressが18文字以上ならエラーになること' do
      machine = build(:machine, company: company)
      machine["mac_address"] = machine["mac_address"] + ":49"
      machine.valid?
      expect(machine.errors[:mac_address]).to include("は不正な値です")
    end
    it 'mac addressが17文字ならエラーになること' do
      machine = build(:machine, company: company)
      machine["mac_address"].chop!
      machine.valid?
      expect(machine.errors[:mac_address]).to include("は不正な値です")
    end
    it 'nameがnilならエラーにならないこと' do
      machine = build(:machine, company: company, name: nil)
      machine.valid?
      expect(machine.errors[:name]).not_to include("を入力してください")
    end
    it 'nameが32文字ならエラーにならないこと' do
      machine = build(:machine, company: company, name: "a" * 32)
      machine.valid?
      expect(machine.errors[:name]).not_to include("は32文字以内で入力してください")
    end
    it 'nameが33文字以上ならエラーになること' do
      machine = build(:machine, company: company, name: "a" * 33)
      machine.valid?
      expect(machine.errors[:name]).to include("は32文字以内で入力してください")
    end
  end
end
