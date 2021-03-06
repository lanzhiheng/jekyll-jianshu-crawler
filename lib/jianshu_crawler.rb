# coding: utf-8
require 'wombat'
require 'reverse_markdown'
require 'colorator'
require_relative './progressing'

BASE_URL = ENV["JIANSHU_URL"]

USER_SUFFIX = "u/#{ENV["JIANSHU_USER"]}?order_by=shared_at"

USER_URL = "#{BASE_URL}/#{USER_SUFFIX}"

LOADING_CHAR = "#"

# use Class replace Hash, we have getter and setter
class Article
  attr_accessor :title, :body, :time

  def initialize(title, body, time)
    self.title = title
    self.body = format_article(body)
    self.time = time
  end

  def format_article(article_body)
    ReverseMarkdown.convert(article_body, unknow_tags: :raise, github_flavored: true)
  end
end

class JianShuCrawler
  include Custom::Progressing

  attr_reader :articles_dict

  def initialize
    @link_list = []
    @articles_dict = {}
    collected_link
    fetch_all_page
  end

  def collected_link
    page = 1
    puts "Fetching some information of the website"

    page += 1 until fetch_content(page).nil?
    puts "We have #{page.to_s.green} Pages, and #{@link_list.size.to_s.green} Articles"
  end

  def fetch_content(page)
    jianshu_crawler_class = Class.new do
      include Wombat::Crawler
      package_url = "#{USER_URL}&page=#{page}"
      base_url package_url
    end

    jianshu = jianshu_crawler_class.new

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

  def package_article(context)
    # Article attribute
    title = context.css("h1.title").text
    # html format
    body = context.css("div.article div.show-content").to_html
    time = context.css("div.info span.publish-time").text.gsub('*', '')
    Article.new(title, body, time)
  end

  def add_article(context)
    category = context.css("div.show-foot .notebook span").text
    article = package_article(context)
    @articles_dict[category].nil? ? @articles_dict[category] = [article] : @articles_dict[category] << article
  end

  def fetch_all_page
    @finished_articles = 0

    @link_list.each { |link|
      # 封装文章的链接
      article_link = "#{BASE_URL}#{link}"

      article_crawler_class = Class.new do
        include Wombat::Crawler
        package_url = article_link
        base_url package_url
      end

      article_crawler = article_crawler_class.new

      article_crawler.crawl
      context = article_crawler.instance_variable_get('@context')

      add_article(context)

      @finished_articles += 1
      percentage = (@finished_articles.to_f / @link_list.size) * 100

      print "Downloading #{format_terminal_progressing(percentage)} #{percentage.round}%\r".red
      $stdout.flush
    }

    puts "finished #{format_terminal_progressing(100)} #{100}%      ".green
    puts "Download #{@link_list.size.to_s.green} articles"
  end
end
