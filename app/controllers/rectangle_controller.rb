require 'uri'

class RectangleController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:import_background]
  DIRECTORY = 'app/assets/images/rectangles'

  def index
    respond_to do |format|
      format.html
      format.json { render json: @images = Dir.glob('app/assets/images/rectangles/*.{JPG,jpg,jpeg,png,PNG}') }
    end
  end

  def import_background
    name =  params['file'].original_filename
    path = File.join(DIRECTORY, name)
    File.open(path, "wb") { |f| f.write(params['file'].read) }
    @file_name = path
    respond_to do |format|
      format.json { render json: @file_name, :status => 200 }
    end
  end

  def delete_background
    name = params[:src].split('/').last
    path = File.join(DIRECTORY, name)
    File.delete URI.unescape path
    deleted = true
    respond_to do |format|
      format.json { render json: deleted, :status => 200 }
    end
  end

end
