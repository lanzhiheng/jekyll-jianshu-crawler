# coding: utf-8
require 'wombat'
require 'pry'
require 'reverse_markdown'

BASE_URL = "http://www.jianshu.com".freeze

USER_SUFFIX = "u/a8522ac98584?order_by=shared_at".freeze

USER_URL = "#{BASE_URL}/#{USER_SUFFIX}".freeze

class JianShu
  attr_reader :all_articles

  def initialize
    @link_list = []
    @all_articles = []
    collected_link
    fetch_all_page
  end

  def collected_link
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
    jianshu.crawl

    context = jianshu.instance_variable_get('@context')
    result = context.css('li .content .title')

    if result.size.zero?
      nil
    else
      @link_list += result.map {|i| i.attributes["href"].value}
    end
  end

  def format_article
    @all_articles.map! { |article|
      article[:body] = ReverseMarkdown.convert(article[:body])
      article
    }
  end

  def fetch_all_page
    @link_list.each { |link|
      # 封装文章的链接
      article_link = "#{BASE_URL}#{link}"

      temp_class = Class.new do
        include Wombat::Crawler
        package_url = article_link
        base_url package_url
      end

      article_crawler = temp_class.new

      article_crawler.crawl
      context = article_crawler.instance_variable_get('@context')

      article = {
        title: context.css("h1.title").text,
        body: context.css("div.article div.show-content").to_html,
        category: context.css("div.show-foot .notebook span").text,
        time: context.css("div.info span.publish-time").text.gsub('*', '')
      }
      @all_articles.push(article)
    }

    format_article
  end
end
