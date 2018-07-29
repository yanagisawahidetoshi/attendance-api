# frozen_string_literal: true

require 'faker'
require 'rails_helper'

RSpec.describe CustomTime do
  describe 'round_time' do
    context '切り上げ' do
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 10:00')
        expect(CustomTime.round_time(time, 'up')).to eq '10:00'
      end
      it '15分に丸められること' do
        time = DateTime.parse('2018-10-10 13:14')
        expect(CustomTime.round_time(time, 'up')).to eq '13:15'
      end
      it '30分に丸められること' do
        time = DateTime.parse('2018-10-10 10:20')
        expect(CustomTime.round_time(time, 'up')).to eq '10:30'
      end
      it '45分に丸められること' do
        time = DateTime.parse('2018-10-10 10:41')
        expect(CustomTime.round_time(time, 'up')).to eq '10:45'
      end
      it '00分に丸められ時刻が繰り上がるれること' do
        time = DateTime.parse('2018-10-10 10:59')
        expect(CustomTime.round_time(time, 'up')).to eq '11:00'
      end
    end
    context '切り捨て' do
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 10:00')
        expect(CustomTime.round_time(time, 'down')).to eq '10:00'
      end
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 13:14')
        expect(CustomTime.round_time(time, 'down')).to eq '13:00'
      end
      it '15分に丸められること' do
        time = DateTime.parse('2018-10-10 10:20')
        expect(CustomTime.round_time(time, 'down')).to eq '10:15'
      end
      it '30分に丸められること' do
        time = DateTime.parse('2018-10-10 10:41')
        expect(CustomTime.round_time(time, 'down')).to eq '10:30'
      end
      it '45分に丸められること' do
        time = DateTime.parse('2018-10-10 10:59')
        expect(CustomTime.round_time(time, 'down')).to eq '10:45'
      end
    end
  end
end
