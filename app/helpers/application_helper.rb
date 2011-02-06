module ApplicationHelper
  def tag_cloud_limited(tags, classes, limit)
    tags = tags.all if tags.respond_to?(:all)

    return [] if tags.empty?

    max_count = tags.sort_by(&:count).last.count.to_f
    public_tags = Array.new
    tags.each do |tag|
      shared = true
      if tag[:count] == 1
        share = false
      elsif tag[:count] > 1
        Bookmark.tagged_with(tag.name).all.each do |bookmark|
          if bookmark.private?
            shared = false
            return
          end
        end
      end
      public_tags << tag if shared
    end
    tags = public_tags.sort_by(&:count).last(limit).sort_by(&:name)

    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end
end
