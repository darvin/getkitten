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


get '/hi' do
  @width = params[:width]
  @height = params[:height]
  xml = clnt.get(target, 
  { 
    "api_key" => API_KEY, 
    "format" => "xml",
    "results_per_page" => 1,
    "type" => "png",
    "size" => "small",
  }
  ).content
  parsed_xml = XmlSimple.xml_in(xml)
  image_url = parsed_xml["data"][0]["images"][0]["image"][0]["url"][0]
  puts image_url
  
  
  image = Magick::ImageList.new  
  urlimage = open(image_url) 
  image.from_blob(urlimage.read)
  


  send_file(image.path, :disposition => "inline")
  
end