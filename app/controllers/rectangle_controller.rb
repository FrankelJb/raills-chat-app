class RectangleController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:import_background]
  
  def index
    puts 'import_background'
  end

  def import_background
    name =  params['file'].original_filename
    p params
    directory = 'app/assets/images/'
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params['file'].read) }
    @file_name = 'success'
    respond_to do |format|
       format.json { render json: @file_name, :status => 200 }
    end
  end

end
