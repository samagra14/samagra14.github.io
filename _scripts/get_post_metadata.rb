#!/usr/bin/env ruby
require 'yaml'
require 'date'

# 1. Get list of added files in the latest commit
#    We use git diff to find files added (A) in the last commit
added_files = `git diff --diff-filter=A --name-only HEAD~1 HEAD`.split("\n")

# 2. Filter for posts in _posts/
new_post = added_files.find { |f| f.match?(/^_posts\/.*\.md$/) }

if new_post
  puts "Found new post: #{new_post}"
  
  # 3. Read Front Matter to get Title
  content = File.read(new_post)
  if content =~ /\A(---\s*\n.*?\n?)^---\s*$\n/m
    front_matter = YAML.load($1)
    title = front_matter['title']
  end

  # 4. Construct URL from filename
  #    Format: _posts/YYYY-MM-DD-title.md -> /year/month/day/title.html
  #    (Assuming default Jekyll permalink style: /:categories/:year/:month/:day/:title/)
  basename = File.basename(new_post, ".md")
  match = basename.match(/(\d{4})-(\d{2})-(\d{2})-(.*)/)
  
  if match && title
    year, month, day, slug = match.captures
    # Adjust this based on your actual permalink setting in _config.yml
    # Current config seems standard.
    # Note: If you have categories, they might be in the URL, but usually /year/month/day/slug is a safe fallback or redirect.
    # Let's check _config.yml for 'permalink'. If not set, it defaults to /:categories/:year/:month/:day/:title/
    
    # We will assume standard date-based URL for now.
    url = "https://samagra.me/#{year}/#{month}/#{day}/#{slug}.html" # Using domain from _config.yml

    # 5. Export to GitHub Actions Environment
    #    See: https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-environment-variable
    File.open(ENV['GITHUB_ENV'], 'a') do |f|
      f.puts "POST_TITLE=#{title}"
      f.puts "POST_URL=#{url}"
      f.puts "NEW_POST_FOUND=true"
    end
    
    puts "Exported: POST_TITLE='#{title}', POST_URL='#{url}'"
  else
    puts "Could not parse filename or title."
  end
else
  puts "No new posts found in this commit."
  File.open(ENV['GITHUB_ENV'], 'a') do |f|
    f.puts "NEW_POST_FOUND=false"
  end
end
