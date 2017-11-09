require 'dotenv/load'
require './lib/jekyll_article'

JekyllArticle.new.generate_file
