require 'nokogiri'
require 'xml'
require 'xlink'

module XBRL
  module XLink
    # Implements xl:documentation
    module Documentation
      include XmlElement
      
      # documentation MUST have string content
      def to_s
        content
      end
    end

    module Locator
      include ::XLink::Locator
      
      # xlink:type MUST be "locator"
      # xlink:href is REQUIRED
      # xlink:label is REQUIRED
      
      def title_type_elements(ns = NS_XL)
        super(ns)
      end
    end
    
    # defines local resources
    module Resource
      include ::XLink::Resource
      
      # xlink:type MUST be "resource"
      # xlink:label is REQUIRED
      # xlink:role is optional.
    end
    
    # The semantics of xl:arc are **complicated**, but they're documented at:
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.3.9
    module Arc
      include ::XLink::Arc
      
      # xlink:type MUST be "arc"
      # xlink:from is REQUIRED
      # xlink:to is REQUIRED
      # xlink:arcrole is REQUIRED
      
      # xl:arc specific attributes: order, use, priority
      
      # The optional order attribute MUST have a decimal value that that indicates the order 
      # in which applications MUST display siblings when hierarchical networks of relationships 
      # are being displayed.
      # ...
      # The value of the order attribute is not restricted to integers...
      def order
        qattr(NS_XL, 'order').to_f
      end
      
      # The optional use attribute MUST take one of two possible values – "optional", or "prohibited".
      def use
        qattr(NS_XL, 'use')
      end
      
      # The content of the priority attribute MUST be an integer.
      def priority
        qattr(NS_XL, 'priority').to_i
      end
      
      def title_type_elements(ns = NS_XL)
        super(ns)
      end
    end
    

    module ExtendedLink
      include ::XLink::ExtendedLink
      
      # xlink:type MUST be "extended"
      # xlink:role MUST occur on "standard extended links"
      
      def documentation
        documentation_elements.to_a.map {|n| n.extend Documentation }
      end
      
      # All XBRL extended links MAY contain documentation elements.
      # The documentation elements in extended links conform to the same syntax requirements that apply 
      # to documentation elements in linkbase elements. See Section 3.5.2.3 for details.
      def documentation_elements
        documentation_tag = qname(NS_XL, 'documentation')
        xpath("./#{documentation_tag}")   # this works because . refers to the <linkbase> root tag
      end
      
      def resource_type_elements(ns = NS_XL)
        super(ns)
      end

      def locator_type_elements(ns = NS_XL)
        super(ns)
      end

      def arc_type_elements(ns = NS_XL)
        super(ns)
      end

      def title_type_elements(ns = NS_XL)
        super(ns)
      end
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.1
    module SimpleLink
      include ::XLink::SimpleLink

      # xlink_type MUST be "simple"
      # xlink_href is REQUIRED
    end
  end
end