class SourcefilesController < ApplicationController
  def picker
    @sourcefile = Sourcefile.find(params[:id])
  end
end
