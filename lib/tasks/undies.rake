# because they come in handy
#
# you need a dev config file edit the DEVS path if needed
# this has to be a yml file using syntax :
#
# <github_username>:
#   emails:
#     <first@email.co>
#     <second@email.co>
#
# change <github_username> by the github username (so it can be linked properly with some stuff check markdown task)
# put your emails instead of <first@email.co> .. etc
# this will allow the tasks to find the proper users and link them properly
#
require "net/http"
require "uri"
DEVS = Rails.root.to_s + "/config/devs.yml"

namespace :undies do
  desc "generate changelog with nice clean output"
  task :changelog, :since_c, :until_c do |t,args|
    since_c = args[:since_c] || `git tag | head -1`.chomp
    until_c = args[:until_c]
    cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

    github_authors = YAML::load(File.open(DEVS))

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

  desc "generate full markedown changelog"
  task :markdown, :since_c do |t,args|
    printf("Gathering tags")
    tags = `git tag`.split(/\n/)
    since_c = args[:since_c] || `git tag | tail -1`.chomp
    tags_fleet = Array.new
    (0..(tags.size - 1)).each do |i|
      if i == 0 && tags.size > 1
        tags_fleet[0] = [tags[0], tags[1]]
      elsif tags.size < 2
        tags_fleet = nil
      else
        tags_fleet[i] = [tags[i], tags[i+1]]
      end
      i += 1
    end
    printf(" #{tags.join(', ')}\n")
    commits_hash = Hash.new
    if tags.size > 1
      tags_fleet.each do |tag_duo|
        commits_hash[tag_duo[1]] = `git log --pretty='format:%ci::%an <%ae>::%s::%H' #{tag_duo[0]}..#{tag_duo[1]}`
      end
    end

    changelog_content = String.new
    commits_hash.keys.reverse.each do |tag|
      printf("Handling commits for #{tag} :") if tag
      printf("Handling commits for current :") unless tag
      # setting up the consts
      changelog_content += "\n" unless changelog_content.size == 0
      github_authors = YAML::load(File.open(DEVS))
      entries = Hash.new
      changelog_content += "# #{tag}\n" if tag
      changelog_content += "# current\n" unless tag

      # unfolding the data, splitting up by author
      commits_hash[tag].split("\n").each do |entry|
        date, author, subject, hash = entry.chomp.split("::")
        author_nickname = author
        # getting author nickname/username
        github_authors.each do |ga|          
          author_email = author.split(" ").last.gsub(/[><]/,'')
          author_nickname = ga[0] if ga[1]["emails"].include?(author_email)
        end
        entries[author_nickname] = Array.new unless entries[author_nickname]
        day = date.split(" ").first
        entries[author_nickname] << "#{subject} (#{hash})" unless subject =~ /Merge/
      end
      # formatting the result and adding to the tag changelog
      
      # generate clean output
      authors = Hash.new
      entries.keys.each do |author|
        author_github = {:gravatar => nil, :login => nil, :name => nil, :location => nil}
        github_uri = URI.parse("http://github.com/api/v2/json/user/show/#{author}")
        http = Net::HTTP.new(github_uri.host, github_uri.port)
        response = http.request(Net::HTTP::Get.new(github_uri.request_uri))
        user_data = JSON.parse(response.body)
        author_github = {:gravatar => user_data["user"]["gravatar_id"],
          :login => user_data["user"]["login"],
          :name => user_data["user"]["name"],
          :location => user_data["user"]["location"]}
        authors[author] = author_github
      end
      entries_count = 0
      entries.keys.each do |author|
        author_data = authors[author]
        author_bits = "* #{author_data[:name]} ([#{author_data[:login]}](http://github.com/#{author_data[:login]}))" if author_data[:name]
        author_bits = "* [#{author_data[:login]}](http://github.com/#{author_data[:login]})" unless author_data[:name]
        changelog_content += "#{author_bits} from #{author_data[:location]}\n" if author_data[:location]
        changelog_content += "#{author_bits}\n" unless author_data[:location]
        entries[author].reverse.each do |entry|
          entries_count += 1
          changelog_content += "    * #{entry}\n"
        end
      end

      printf("  (#{entries_count})\n")
    end

    printf("Writing changelog")
    File.open("#{Rails.root.to_s}/AUTO_CHANGELOG.md","w") { |f| f.puts(changelog_content) }
    printf(" done\n")
    
  end

  desc "generate changelog with github output"
  task :github_changelog, :since_c, :until_c do |t,args|
    since_c = args[:since_c] || `git tag | head -1`.chomp
    until_c = args[:until_c]
    cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

    github_authors = YAML::load(File.open(DEVS))

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