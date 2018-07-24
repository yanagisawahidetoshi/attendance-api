# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe Attendance, type: :model do
  let(:user) { build(:user) }
  context 'バリデーション' do
    it 'バリデーションエラーがないこと' do
      expect(build(:attendance, user: user)).to be_valid
    end
    it 'ユーザがなければエラーになること' do
      attendance = build(:attendance, user: nil)
      attendance.valid?
      expect(attendance.errors[:user]).to include('を入力してください')
    end
    it 'dateがなければエラーになること' do
      attendance = build(:attendance, date: nil)
      attendance.valid?
      expect(attendance.errors[:date]).to include('を入力してください')
    end
    it 'dateが日付でなければエラーになること' do
      attendance = build(:attendance, date: 'hogehoge')
      attendance.valid?
      expect(attendance.errors[:date]).to include('を入力してください')
    end
    it 'dateのフォーマットがおかしくてもエラーにならないこと' do
      attendance = build(:attendance, date: Date.current.strftime('%Y/%m/%d'))
      attendance.valid?
      expect(attendance.errors[:date].empty?).to eq true
    end
  end

  context '時刻丸め' do
    it 'in_timeが00分で丸められること' do
      attendance = create(:attendance, user: user, in_time: '2018-10-10 10:14')
      expect(Attendance.first.in_time.strftime('%H:%M')).to eq('10:15')
    end
    it 'out_timeが15分で丸められること' do
      attendance = create(:attendance, user: user, out_time: '2018-10-10 10:29')
      expect(Attendance.first.out_time.strftime('%H:%M')).to eq('10:15')
    end
  end

  context 'recess_hour' do
    describe '正常系' do
      it '1が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 19:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 1
      end
      it '1が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 18:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 1
      end
      it '0.75が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 17:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 0.75
      end
      it '0.75が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 17:59')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 0.75
      end
      it '0.75が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 16:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 0.75
      end
      it '0が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 14:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 0
      end
      it '0が返されること' do
        in_time = DateTime.parse('2018-10-10 10:00')
        out_time = DateTime.parse('2018-10-10 15:59')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, out_time)).to eq 0
      end
    end

    describe 'in_timeがnilの場合' do
      it 'nilを返すこと' do
        out_time = DateTime.parse('2018-10-10 19:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(nil, out_time)).to eq nil
      end
    end

    describe 'out_timeがnilの場合' do
      it 'nilを返すこと' do
        in_time = DateTime.parse('2018-10-10 19:00')
        attendance = Attendance.new
        expect(attendance.recess_hour(in_time, nil)).to eq nil
      end
    end
  end

  context 'round_time' do
    describe '出勤時、切上げられること' do
      it '15分に丸められること' do
        time = DateTime.parse('2018-10-10 10:14')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '10:15'
      end
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 10:00')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '10:00'
      end
      it '30分に丸められること' do
        time = DateTime.parse('2018-10-10 10:20')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '10:30'
      end
      it '45分に丸められること' do
        time = DateTime.parse('2018-10-10 10:41')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '10:45'
      end
      it '00分に丸めら時刻が繰り上がるれること' do
        time = DateTime.parse('2018-10-10 10:59')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '11:00'
      end
      it '00分に丸めら時刻が繰り上がるれること' do
        time = DateTime.parse('2018-10-10 08:59')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'in_time')).to eq '09:00'
      end
    end
    describe '退勤時、切捨て' do
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 10:14')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'out_time')).to eq '10:00'
      end
      it '00分に丸められること' do
        time = DateTime.parse('2018-10-10 10:00')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'out_time')).to eq '10:00'
      end
      it '15分に丸められること' do
        time = DateTime.parse('2018-10-10 10:20')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'out_time')).to eq '10:15'
      end
      it '30分に丸められること' do
        time = DateTime.parse('2018-10-10 10:41')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'out_time')).to eq '10:30'
      end
      it '45分に丸められること' do
        time = DateTime.parse('2018-10-10 10:59')
        attendance = Attendance.new
        expect(attendance.round_time(time, 'out_time')).to eq '10:45'
      end
    end
  end

  context 'build_operating_time' do
    describe '休憩時間がある場合' do
      it '稼動時間が取得できること' do
        attendance = build(:attendance, recess: 1)
        expect(Attendance.new.build_operating_time(attendance)).to eq 8
      end
    end
    describe '休憩時間がない場合' do
      it '稼動時間が取得できること' do
        attendance = build(:attendance)
        expect(Attendance.new.build_operating_time(attendance)).to eq 9
      end
    end
    describe 'in_timeがない場合' do
      it '稼動時間が取得できないこと' do
        attendance = build(:attendance, in_time: nil)
        expect(Attendance.new.build_operating_time(attendance)).to eq nil
      end
    end
    describe 'out_timeがない場合' do
      it '稼動時間が取得できないこと' do
        attendance = build(:attendance, out_time: nil)
        expect(Attendance.new.build_operating_time(attendance)).to eq nil
      end
    end
  end
end
