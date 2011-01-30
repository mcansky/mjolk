# because they come in handy

namespace :undies do
  desc "generate changelog with nice clean output"
  task :changelog, :since_c, :until_c do |t,args|
    since_c = args[:since_c] || `git tag | head -1`.chomp
    until_c = args[:until_c]
    cmd=`git log --pretty='format:%ci::%an <%ae>::%s' #{since_c}..#{until_c}`

    entries = Hash.new
    changelog_content = String.new

    cmd.split("\n").each do |entry|
      date, author, subject = entry.chomp.split("::")
      entries[author] = Array.new unless entries[author]
      day = date.split(" ").first
      entries[author] << subject unless subject =~ /Merge/
    end

    # generate clean output
    entries.keys.each do |author|
      changelog_content += author + "\n"
      entries[author].each { |entry| changelog_content += "  * #{entry}\n" }
    end

    puts changelog_content
  end
end