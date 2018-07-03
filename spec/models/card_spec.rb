require 'rails_helper'
require 'faker'

RSpec.describe Card, type: :model do
  let(:company) { build(:company) }
  context 'バリデーション' do
    it 'バリデーションエラーがないこと' do
      expect(build(:card, company: company)).to be_valid
    end

    it 'CARD IDが無ければ無効であること' do
      card = build(:card, card_id: nil)
      card.valid?
      expect(card.errors[:card_id]).to include('を入力してください')
    end

    it 'CARD IDが65文字以上なら無効であること' do
      card = build(:card, card_id: 'a' * 65)
      card.valid?
      expect(card.errors[:card_id]).to include('は64文字以内で入力してください')
    end

    it 'CARD IDが64文字なら有効であること' do
      card = build(:card, card_id: 'a' * 64)
      card.valid?
      expect(card.errors[:card_id]).not_to include('は64文字以内で入力してください')
    end

    it 'COMPANYがなければ無効であること' do
      card = build(:card)
      card.valid?
      expect(card.errors[:company]).to include('を入力してください')
    end
    
    it 'tokenがなくても有効であること' do
      card = build(:card, token: nil)
      card.valid?
      expect(card.errors[:token]).not_to include('を入力してください')      
    end
    
    it 'tokenが32文字なら有効であること' do
      card = build(:card, token: 'a' * 32)
      card.valid?
      expect(card.errors[:token]).not_to include('は32文字で入力してください') 
    end
    
    it 'tokenが33文字なら無効であること' do
      card = build(:card, token: 'a' * 33)
      card.valid?
      expect(card.errors[:token]).to include('は32文字で入力してください') 
    end
    
    it 'tokenが31文字なら無効であること' do
      card = build(:card, token: 'a' * 31)
      card.valid?
      expect(card.errors[:token]).to include('は32文字で入力してください') 
    end
  end
end
