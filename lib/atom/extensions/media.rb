require 'atom'

#
# Media extension (see http://video.search.yahoo.com/mrss)
#
# Exaple:
#     f.entries << Atom::Entry.new do |e|
#       e.media_content = Media::Content.new :url => article.media['image']
#     end
#

module Media
  class Base
      include Atom::Xml::Parseable
      include Atom::SimpleExtensions

      def initialize(o = {})
        case o
        when XML::Reader
          parse(o, :once => true)
        when Hash
          o.each do |k, v|
            self.send("#{k.to_s}=", v)
          end
        else
          raise ArgumentError, "Got #{o.class} but expected a Hash or XML::Reader"
        end

        yield(self) if block_given?
      end
  end
  
  class Content < Base
    attribute :url, :fileSize, :type, :medium, :isDefault, :expression, :bitrate, :height, :width, :duration, :lang
  end
  
  class Location < Base
    attribute :id, :type
  end
  
  class Category < Base
    attribute :name
  end
end

module Hoodline
  class Metadata < Media::Base
    attribute :automated
  end
end

Atom::Feed.add_extension_namespace :media, "http://search.yahoo.com/mrss/"
Atom::Feed.add_extension_namespace :hl, "http://hoodline.com/"
Atom::Entry.element "media:content", class: Media::Content
Atom::Entry.elements "media:location", class: Media::Location
Atom::Entry.element "media:category", class: Media::Category
Atom::Entry.element "hl:metadata", class: Hoodline::Metadata
