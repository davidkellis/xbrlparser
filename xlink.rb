require 'nokogiri'
require 'pp'


# XLink spec: http://www.w3.org/TR/xlink/
module XLink
  NS = "http://www.w3.org/1999/xlink"
  LINKBASE_ARCROLE = "http://www.w3.org/1999/xlink/properties/linkbase"
  
  # This represents any XLink element
  # Should be mixed into a class derived from XmlElement
  module XLinkElement
    attr_accessor :xlink_type     # type MUST be defined in every type of link except simple; in simple links, either type or href MUST be specified
    attr_accessor :xlink_href     # href MUST be defined in locator-type elements
    attr_accessor :xlink_role
    attr_accessor :xlink_arcrole
    attr_accessor :xlink_title
    attr_accessor :xlink_show
    attr_accessor :xlink_actuate
    attr_accessor :xlink_label
    attr_accessor :xlink_from
    attr_accessor :xlink_to
    
    def set_xlink_attr(attribute_name)
      attr_name = qname(NS, attribute_name)
      attribute = @root.xpath("@#{attr_name}").first    # this should return a Nokogiri::XML::Attr object if the attribute exists
      instance_variable_set("@xlink_#{attribute_name}", attribute.value) if attribute
    end
  end
  
  # defines local resources
  class Resource < XmlElement
    include XLinkElement

    def initialize(root_node)
      super
      
      set_xlink_attr('type')
    end
  end
  
  # defines remote resources
  class Locator < XmlElement
    include XLinkElement
    
    def initialize(root_node)
      super
      
      set_xlink_attr('type')
      set_xlink_attr('href')
    end

    def titles
      unless @titles
        @titles = title_type_elements.to_a.map {|t| Title.new(t) }
      end
      @titles
    end

    def title_type_elements
      unless @title_type_elements
        attr_name = qname(NS, 'type')
        @title_type_elements = @root.xpath("*[@#{attr_name}='title']")
      end
      @title_type_elements
    end
  end
  
  # defines traversal rules
  class Arc < XmlElement
    include XLinkElement
    
    def initialize(root_node)
      super
      
      set_xlink_attr('type')
      set_xlink_attr('arcrole')
    end

    def titles
      unless @titles
        @titles = title_type_elements.to_a.map {|t| Title.new(t) }
      end
      @titles
    end

    def title_type_elements
      unless @title_type_elements
        attr_name = qname(NS, 'type')
        @title_type_elements = @root.xpath("*[@#{attr_name}='title']")
      end
      @title_type_elements
    end
    
    def linkbase?
      @xlink_arcrole == LINKBASE_ARCROLE
    end
  end
  
  class Title < XmlElement
    include XLinkElement

    def initialize(root_node)
      super
      
      set_xlink_attr('type')
    end
  end

  class Link < XmlElement
    include XLinkElement
    
    def initialize(root_node)
      super
      
      set_xlink_attr('type')
    end
  end
  
  class ExtendedLink < Link
    def resources
      unless @resources
        @resources = resource_type_elements.to_a.map {|r| Resource.new(r) }
      end
      @resources
    end
    
    def locators
      unless @locators
        @locators = locator_type_elements.to_a.map {|l| Locator.new(l) }
      end
      @locators
    end
    
    def arcs
      unless @arcs
        @arcs = arc_type_elements.to_a.map {|a| Arc.new(a) }
      end
      @arcs
    end

    def titles
      unless @titles
        @titles = title_type_elements.to_a.map {|t| Title.new(t) }
      end
      @titles
    end

    # returns a NodeSet
    def resource_type_elements
      unless @resource_type_elements
        attr_name = qname(NS, 'type')
        @resource_type_elements = @root.xpath("*[@#{attr_name}='resource']")
      end
      @resource_type_elements
    end

    def locator_type_elements
      unless @locator_type_elements
        attr_name = qname(NS, 'type')
        @locator_type_elements = @root.xpath("*[@#{attr_name}='locator']")
      end
      @locator_type_elements
    end
    
    def arc_type_elements
      unless @arc_type_elements
        attr_name = qname(NS, 'type')
        @arc_type_elements = @root.xpath("*[@#{attr_name}='arc']")
      end
      @arc_type_elements
    end
    
    def title_type_elements
      unless @title_type_elements
        attr_name = qname(NS, 'type')
        @title_type_elements = @root.xpath("*[@#{attr_name}='title']")
      end
      @title_type_elements
    end
  end
  
  class SimpleLink < Link
    def initialize(root_node)
      super
      
      set_xlink_attr('href')
      set_xlink_attr('arcrole')
    end
    
    def linkbase?
      @xlink_arcrole == LINKBASE_ARCROLE
    end
  end
end

module XBRL
  module XLink
    class ExtendedLink < ::XLink::ExtendedLink
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.1
    class SimpleLink < ::XLink::SimpleLink
      # xlink_type MUST be "simple"
      # xlink_href is REQUIRED
    end
  end
end