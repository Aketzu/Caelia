class Recording < ActiveRecord::Base
  has_many :sourcefiles
  has_many :vods

  def filepath
    basepath + "/" + name
  end


end
