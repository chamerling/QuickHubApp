require 'rubygems'
require 'rake'
require 'fileutils'
require 'stringex'

posts_dir = "_posts"    # directory for blog files
new_post_ext = "markdown"  # default new post file extension when using the new_post task

# usage rake new
desc "Begin a new post in #{posts_dir}"
task :new do
  require './_plugins/titlecase.rb'
  
  puts "What should we call this post for now?"
  name = STDIN.gets.chomp
  
  mkdir_p "#{posts_dir}"
  title = name
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    system "mkdir -p #{posts_dir}/";
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;').titlecase}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
end

desc "Startup Jekyll"
task :start do
  sh "jekyll --server"
end

task :default => :start
