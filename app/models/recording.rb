class Recording < ActiveRecord::Base
  has_many :sourcefiles
  has_many :vods

  def filepath
    basepath + "/" + name
  end

  def age
    Time.now - self.sourcefiles.last.recorded_at rescue 9999999
  end

  def statusclass
    case age
      when 0..900
        "success"
    end
  end

end
