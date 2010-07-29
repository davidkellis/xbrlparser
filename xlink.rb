require 'nokogiri'
require 'pp'

# XLink spec: http://www.w3.org/TR/xlink/
module XLink
  NS = "http://www.w3.org/1999/xlink"
  LINKBASE_ARCROLE = "http://www.w3.org/1999/xlink/properties/linkbase"
  
  # This represents any XLink element
  # Should be mixed into a class derived from XmlElement
  module XLinkElement
    # XLink element type attribute: type
    def xlink_type     # type MUST be defined in every type of link except simple; in simple links, either type or href MUST be specified
      @xlink_type ||= get_xlink_attr('type')
    end
    
    # locator attribute: href
    def xlink_href     # href MUST be defined in locator-type elements
      @xlink_href ||= get_xlink_attr('href')
    end
    
    # semantic attributes: role, arcrole, title
    def xlink_role      # this identifier MUST NOT be a relative [Legacy Extended IRI]
      @xlink_role ||= get_xlink_attr('role')
    end
    def xlink_arcrole   # this identifier MUST NOT be a relative [Legacy Extended IRI]
      @xlink_arcrole ||= get_xlink_attr('arcrole')
    end
    def xlink_title
      @xlink_title ||= get_xlink_attr('title')
    end
    
    # behavior attributes: show, actuate
    def xlink_show
      @xlink_show ||= get_xlink_attr('show')
    end
    def xlink_actuate
      @xlink_actuate ||= get_xlink_attr('actuate')
    end
    
    # traversal attributes: label, from, to
    def xlink_label
      @xlink_label ||= get_xlink_attr('label')
    end
    def xlink_from
      @xlink_from ||= get_xlink_attr('from')
    end
    def xlink_to
      @xlink_to ||= get_xlink_attr('to')
    end
    
    def get_xlink_attr(attribute_name)
      attr_name = qname(NS, attribute_name)
      attribute = @root.xpath("@#{attr_name}").first    # this should return a Nokogiri::XML::Attr object if the attribute exists
      #instance_variable_set("@xlink_#{attribute_name}", attribute.value) if attribute
      attribute.value if attribute
    end
  end
  
  # defines local resources
  class Resource < XmlElement
    include XLinkElement
  end
  
  # defines remote resources
  class Locator < XmlElement
    include XLinkElement

    def xlink_href
      href = super
      resolve_href_uri(base, href)
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
  end

  class Link < XmlElement
    include XLinkElement
  end
  
  class ExtendedLink < Link
    def resources
      @resources ||= resource_type_elements.to_a.map {|n| Resource.new(n, self) }
    end
    
    def locators
      @locators ||= locator_type_elements.to_a.map {|n| Locator.new(n, self) }
    end
    
    def arcs
      @arcs ||= arc_type_elements.to_a.map {|n| Arc.new(n, self) }
    end

    def titles
      @titles ||= title_type_elements.to_a.map {|n| Title.new(n, self) }
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
    def xlink_href
      href = super
      resolve_href_uri(base, href)
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