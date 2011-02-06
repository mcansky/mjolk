require 'net/http'
require "net/https"
require 'uri'
require 'json'

class Link < ActiveRecord::Base
  has_many :bookmarks
  has_many :users, :through => :bookmarks
  validates_presence_of :url
  validates_uniqueness_of :url, :case_sensitive => true
  before_save :shorten

  def shorten
    if short_url == nil
      data = {"longUrl" => url}.to_json
      google_payload = "/urlshortener/v1/url?key=#{Settings.goo_gl.api}"
      host = "www.googleapis.com"
      port = "443"

      req = Net::HTTP::Post.new(google_payload, initheader = {'Content-Type' =>'application/json'})
      req.body = data
      httpd = Net::HTTP.new(host, port)
      httpd.use_ssl = true
      response = httpd.request(req)
      json_res = JSON.parse(response.body)
      self.short_url = json_res["id"]
    end
  end
end
