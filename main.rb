require 'octokit'
require 'csv'
require 'byebug'

if ARGV.length != 5
  puts 'Must provide <github api url> <github personal access token> <org> <repo> <branch>'
  exit
end

api_url = ARGV[0]
token = ARGV[1]
org = ARGV[2]
repo = ARGV[3]
branch = ARGV[4]

Octokit.configure do |c|
  c.api_endpoint = api_url
  c.auto_paginate = true
end

# get all commits
client = Octokit::Client.new(access_token: token)
commits = client.commits("#{org}/#{repo}", branch)
puts "# Commits: #{commits.length}"

# group commits by year-month
commits_by_month = commits.reverse.group_by do |c|
  c[:commit][:author][:date].to_date.strftime('%Y-%m')
end

# clone repo
ssh_url = client.repository("#{org}/#{repo}")[:ssh_url]
puts "git clone #{ssh_url}"
`git clone #{ssh_url}`

# save LOC for each year-month to CSV
timestamp = DateTime.now.strftime('%Y%m%d_%H%M%S')
output_file = "output/#{repo}-loc-#{timestamp}.csv"

CSV.open(output_file, 'w', write_headers: true, headers: ['Month', 'SHA', 'LOC']) do |csv|
  commits_by_month.each_with_index do |values, i|
    month = values[0]
    cs = values[1]
    sha = cs.first[:sha]
    puts "(#{i + 1}/#{commits_by_month.length}) #{month}: #{sha}"

    cloc = `cd #{repo} && git checkout #{sha} && cloc -csv --quiet .`

    rows = CSV.parse(cloc.strip, headers: true)
    loc = if rows.empty?
      0
    else
      rows[rows.length - 1]['code'] # total
    end
    puts "LOC: #{loc}"

    csv << [month, sha, loc]
  end
end

# delete repo
`rm -rf #{repo}`

puts "output file saved at #{output_file}"
