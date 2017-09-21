require 'wombat'
require 'pry'

BASE_URL = "http://www.jianshu.com".freeze

USER_SUFFIX = "u/a8522ac98584?order_by=shared_at".freeze

USER_URL = "#{BASE_URL}/#{USER_SUFFIX}"

class JianShu
  def initialize
    @link_list = []
  end

  def minilize
    page = 1

    page += 1 until fetch_content(page).nil?
  end

  def fetch_content(page)
    puts page
    temp_class = Class.new do
      include Wombat::Crawler
      package_url = "#{USER_URL}&page=#{page}"
      base_url package_url
    end

    jianshu = temp_class.new

    mechanize_object = jianshu.instance_variable_get('@mechanize')

    mechanize_object.request_headers = {"X-INFINITESCROLL" => true}

    # fetch url
    result = jianshu.crawl

    context = jianshu.instance_variable_get('@context')
    result = context.css('li .content .title')

    if result.size.zero?
      nil
    else
      @link_list += result.map {|i| i.attributes["href"].value}
    end
  end
end




jianshu = JianShu.new
jianshu.minilize
p jianshu.instance_variable_get('@link_list')
