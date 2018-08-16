# frozen_string_literal: true

class CustomTime
  class << self
    def round_time(time, round)
      hour = time.strftime('%H').to_i
      min = (time.strftime('%M').to_f / 15.to_f)
      if round == 'up'
        min, hour = round_up(min, hour)
      elsif round == 'down'
        min = round_down(min)
      end
      "#{format('%02d', hour)}:#{format('%02d', min)}"
    end

    private

    def round_up(min, hour)
      min = min.ceil * 15
      return min, hour unless min == 60

      min = 0o0
      hour += 1
      [min, hour]
    end

    def round_down(min)
      min.floor * 15
    end
  end
end
