require 'sinatra'
require 'net/http'
require 'xmlsimple'
require 'RMagick'
require "open-uri"
require 'net/http'
require 'cgi'

set :public_folder, 'public'


class String
  def to_bool
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

def http_get(domain,path,params)
    return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))) if not params.nil?
    return Net::HTTP.get(domain, path)
end



def round(source_image, radius = 10)

  mask = Magick::Image.new(source_image.columns, source_image.rows) {self.background_color = 'transparent'}

  # Create a white rectangle with rounded corners. This will become the
  # mask for the area you want to retain in the original image.
  Magick::Draw.new.stroke('none').stroke_width(0).fill('white').
      roundrectangle(0, 0, source_image.columns, source_image.rows, radius, radius).
      draw(mask)

  # Apply the mask and write it out
  source_image.composite!(mask, 0, 0, Magick::CopyOpacityCompositeOp)
  source_image
end

get "/" do
  redirect '/index.html'
end


API_KEY = "NzQxOQ"


get '/kitten.png' do
  @width = params[:width].to_i
  @height = params[:height].to_i
  @round = params[:rounded]? params[:rounded].to_bool : false
  
  if (@width)
    if (@width>0&&@width<=250)
      size = "small"
    elsif (250<@width&&@width<=500)
      size = "med"
    else
      size = "full"
    end
  end
  
  xml = http_get("thecatapi.com", "/api/images/get", 
  { 
    "api_key" => API_KEY, 
    "format" => "xml",
    "results_per_page" => 1,
    "type" => "png",
    "size" => size,
  }
  )
  parsed_xml = XmlSimple.xml_in(xml)
  image_url = parsed_xml["data"][0]["images"][0]["image"][0]["url"][0]
  puts image_url
  
  
  image = Magick::ImageList.new  
  urlimage = open(image_url) 
  image.from_blob(urlimage.read)
  

  if (@width>0&&@height>0)
    image = image.resize_to_fit(@width, @height)
  elsif (@width>0)
    image = image.resize_to_fit(@width)
  end
  
  if (@round)
    image = round(image)
  end
    

  content_type 'image/png'
  image.format = 'png'
  image.to_blob
  
end