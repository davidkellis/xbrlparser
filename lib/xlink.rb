require 'nokogiri'
require 'xml'
require 'leiri'

# XLink spec: http://www.w3.org/TR/xlink/
module XLink
  NS_XLINK = "http://www.w3.org/1999/xlink"
  LINKBASE_ARCROLE = "http://www.w3.org/1999/xlink/properties/linkbase"
  
  # This represents any XLink element
  module XLinkElement
    include XmlElement
    
    # XLink element type attribute: type
    def xlink_type     # type MUST be defined in every type of link except simple; in simple links, either type or href MUST be specified
      qattr(NS_XLINK, 'type')
    end
    
    # locator attribute: href
    # XLink 1.1 Section 5.4: The value of the href attribute is a [Legacy extended IRIs] (LEIRI).
    def xlink_href     # href MUST be defined in locator-type elements
      qattr(NS_XLINK, 'href')
    end
    
    # semantic attributes: role, arcrole, title
    def xlink_role      # this identifier MUST NOT be a relative [Legacy Extended IRI]
      qattr(NS_XLINK, 'role')
    end
    def xlink_arcrole   # this identifier MUST NOT be a relative [Legacy Extended IRI]
      qattr(NS_XLINK, 'arcrole')
    end
    def xlink_title
      qattr(NS_XLINK, 'title')
    end
    
    # behavior attributes: show, actuate
    def xlink_show
      qattr(NS_XLINK, 'show')
    end
    def xlink_actuate
      qattr(NS_XLINK, 'actuate')
    end
    
    # traversal attributes: label, from, to
    def xlink_label
      qattr(NS_XLINK, 'label')
    end
    def xlink_from
      qattr(NS_XLINK, 'from')
    end
    def xlink_to
      qattr(NS_XLINK, 'to')
    end
  end
  
  # defines local resources
  module Resource
    include XLinkElement
  end
  
  # defines remote resources
  module Locator
    include XLinkElement

    def xlink_href
      LegacyExtendedIRI.new(super).to_target(base)
    end

    def titles
      title_type_elements.to_a.map {|n| n.extend(Title) }
    end

    def title_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='title']")
    end
  end
  
  # defines traversal rules
  module Arc
    include XLinkElement

    def titles
      title_type_elements.to_a.map {|n| n.extend(Title) }
    end

    def title_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='title']")
    end
    
    def linkbase?
      xlink_arcrole == LINKBASE_ARCROLE
    end
  end
  
  module Title
    include XLinkElement
  end

  module Link
    include XLinkElement
  end
  
  module ExtendedLink
    include Link
    
    # xlink:type MUST be "extended"
    
    def resources
      resource_type_elements.to_a.map {|n| n.extend Resource }
    end
    
    def locators
      locator_type_elements.to_a.map {|n| n.extend Locator }
    end
    
    def arcs
      arc_type_elements.to_a.map {|n| n.extend Arc }
    end

    def titles
      title_type_elements.to_a.map {|n| n.extend Title }
    end

    # returns a NodeSet
    def resource_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='resource']")
    end

    def locator_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='locator']")
    end
    
    def arc_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='arc']")
    end
    
    def title_type_elements(ns = NS_XLINK)
      attr_name = qname(ns, 'type')
      xpath("*[@#{attr_name}='title']")
    end
  end
  
  # Either type or href (or both) must be specified in a simple link.
  module SimpleLink
    include Link
    
    # xlink:type is optional, but if it is provided it MUST be "simple"
    
    def xlink_href
      LegacyExtendedIRI.new(super).to_target(base)
    end
    
    def linkbase?
      xlink_arcrole == LINKBASE_ARCROLE
    end
  end
end
