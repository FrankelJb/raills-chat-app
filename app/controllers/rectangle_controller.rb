require 'uri'

class RectangleController < ApplicationController
  DIRECTORY = 'app/assets/images/rectangles'

  def index
    Dir.mkdir(DIRECTORY) unless File.exists?(DIRECTORY)
    get_images
    respond_to do |format|
      format.html
      format.js
    end
  end

  def get_images
    @images = []
    Dir.chdir("#{Rails.root}/app/assets/images/rectangles") do
      @images = Dir["**"].each {|f| @images << f}
    end
  end

  def import_background
    name = params['file'].original_filename
    path = File.join(DIRECTORY, name)
    File.open(path, "wb") { |f| f.write(params['file'].read) }
    @file_name = path
    get_images
    respond_to do |format|
      format.json { render partial: 'import_background' }
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
