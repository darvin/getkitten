require 'sinatra'
require 'net/http'
require 'httpclient'
require 'xmlsimple'
require 'RMagick'
require "open-uri"


get '/' do
    "get kitten: 
    /api/"
end


proxy = ENV['HTTP_PROXY']
clnt = HTTPClient.new(proxy)
# clnt.set_cookie_store("cookie.dat")
target = ARGV.shift || "http://thecatapi.com/api/images/get"
API_KEY = "NzQxOQ"


get '/kitten.png' do
  @width = params[:width].to_i
  @height = params[:height].to_i
  
  if (@width)
    if (@width>0&&@width<=250)
      size = "small"
    elsif (250<@width&&@width<=500)
      size = "med"
    else
      size = "full"
    end
  end
  
  xml = clnt.get(target, 
  { 
    "api_key" => API_KEY, 
    "format" => "xml",
    "results_per_page" => 1,
    "type" => "png",
    "size" => size,
  }
  ).content
  parsed_xml = XmlSimple.xml_in(xml)
  image_url = parsed_xml["data"][0]["images"][0]["image"][0]["url"][0]
  puts image_url
  
  
  image = Magick::ImageList.new  
  urlimage = open(image_url) 
  image.from_blob(urlimage.read)
  

  if (@width>0&&@height>0)
    resized_image = image.resize_to_fit(@width, @height)
  elsif (@width>0)
    resized_image = image.resize_to_fit(@width)
  else
    resized_image = image
  end

  content_type 'image/png'
  resized_image.format = 'png'
  resized_image.to_blob
  
end