# because they come in handy
require "net/http"
require "uri"

namespace :undies do
  desc "generate changelog with nice clean output"
  task :changelog, :since_c, :until_c do |t,args|
    since_c = args[:since_c] || `git tag | head -1`.chomp
    until_c = args[:until_c]
    cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

    github_authors = YAML::load(File.open(Rails.root.to_s + "/config/devs.yml"))

    entries = Hash.new
    changelog_content = String.new

    cmd.split("\n").each do |entry|
      date, author, subject, hash = entry.chomp.split("::")
      entries[author] = Array.new unless entries[author]
      day = date.split(" ").first
      entries[author] << "#{subject} (#{hash})" unless subject =~ /Merge/
    end

    # generate clean output
    entries.keys.each do |author|
      author_email = author.split(" ").last.gsub(/[><]/,'')
      author_github = {:gravatar => nil, :login => nil, :name => nil, :location => nil}
      github_authors.each do |ga|
        if ga[1]["emails"].include?(author_email)
          github_uri = URI.parse("http://github.com/api/v2/json/user/show/#{ga[0]}")
          http = Net::HTTP.new(github_uri.host, github_uri.port)
          response = http.request(Net::HTTP::Get.new(github_uri.request_uri))
          user_data = JSON.parse(response.body)
          author_github = {:gravatar => user_data["user"]["gravatar_id"],
            :login => user_data["user"]["login"],
            :name => user_data["user"]["name"],
            :location => user_data["user"]["location"]}
        end
      end
      author_bits = "* #{author_github[:name]} (#{author_github[:login]} : http://github.com/#{author_github[:login]})" if author_github[:name]
      author_bits = "* #{author_github[:login]} (http://github.com/#{author_github[:login]})" unless author_github[:name]
      changelog_content = "#{author_bits} from #{author_github[:location]}\n" if author_github[:location]
      changelog_content = "#{author_bits}\n" unless author_github[:location]
      entries[author].reverse.each { |entry| changelog_content += "    * #{entry}\n" }
    end

    puts changelog_content
  end

  desc "generate changelog with github output"
  task :github_changelog, :since_c, :until_c do |t,args|
    since_c = args[:since_c] || `git tag | head -1`.chomp
    until_c = args[:until_c]
    cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

    github_authors = YAML::load(File.open(Rails.root.to_s + "/config/devs.yml"))

    entries = Hash.new
    changelog_content = String.new

    cmd.split("\n").each do |entry|
      date, author, subject, hash = entry.chomp.split("::")
      entries[author] = Array.new unless entries[author]
      day = date.split(" ").first
      entries[author] << "#{subject} (#{hash})" unless subject =~ /Merge/
    end

    # generate clean output
    entries.keys.each do |author|
      author_email = author.split(" ").last.gsub(/[><]/,'')
      author_github = {:gravatar => nil, :login => nil, :name => nil, :location => nil}
      github_authors.each do |ga|
        if ga[1]["emails"].include?(author_email)
          github_uri = URI.parse("http://github.com/api/v2/json/user/show/#{ga[0]}")
          http = Net::HTTP.new(github_uri.host, github_uri.port)
          response = http.request(Net::HTTP::Get.new(github_uri.request_uri))
          user_data = JSON.parse(response.body)
          author_github = {:gravatar => user_data["user"]["gravatar_id"],
            :login => user_data["user"]["login"],
            :name => user_data["user"]["name"],
            :location => user_data["user"]["location"]}
        end
      end
      author_bits = "* #{author_github[:name]} ([#{author_github[:login]}](http://github.com/#{author_github[:login]}))" if author_github[:name]
      author_bits = "* [#{author_github[:login]}](http://github.com/#{author_github[:login]})" unless author_github[:name]
      changelog_content = "#{author_bits} from #{author_github[:location]}\n" if author_github[:location]
      changelog_content = "#{author_bits}\n" unless author_github[:location]
      entries[author].reverse.each { |entry| changelog_content += "    * #{entry}\n" }
    end

    puts changelog_content
  end
end