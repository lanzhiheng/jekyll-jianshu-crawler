# coding: utf-8
require 'tilt'
require_relative './jianshu_crawler'

class JekyllArticle
  def initialize
    @jianshu = JianShu.new
  end

  def package_file_name(article)
    title = article.title
    time = article.time
    formated_title = title.gsub(/[ ，{},.《》''?？]/, '')
    formated_time = Date.strptime(time, '%Y.%m.%d').to_s

    "#{formated_time}-#{formated_title}.md"
  end

  def generate_file
    puts "Ready to generate files:"

    current_path = File.dirname(__FILE__)
    # location for articles
    article_dir = ENV['ARTICLE_DIR'] || 'article'
    target_path = File.join('.', article_dir)

    begin
      Dir.mkdir(target_path)
    rescue Errno::EEXIST => e
      # If exists
      require "fileutils"
      FileUtils.rm_rf(target_path)
      retry
    end

    template = Tilt.new(File.join(current_path, 'site_template.erb'))
    @jianshu.articles_dict.each do |category, category_articles|
      category_path = File.join(target_path, category)
      Dir.mkdir(category_path)

      category_articles.each do |article|
        begin
          content = template.render(self,
                                    :title => article.title,
                                    :body => article.body,
                                    :time => article.time
                                   )
          f = File.new(File.join(category_path, package_file_name(article)), "w")
          f.write(content)
          f.close
        rescue Exception => e
          p e
        end
      end
    end

    puts "Files existed in #{article_dir} directory."
  end
end
