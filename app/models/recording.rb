# frozen_string_literal: true

class Recording < ActiveRecord::Base
  has_many :sourcefiles
  has_many :vods

  def filepath
    "#{basepath}/#{name}"
  end

  def age
    Time.now - sourcefiles.last.recorded_at
  rescue StandardError
    9_999_999
  end

  def statusclass
    case age
    when 0..900
      'success'
    end
  end
end
