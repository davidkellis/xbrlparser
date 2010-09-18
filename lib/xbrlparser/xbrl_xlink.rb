
module XBRL
  module XLink
    # Implements xl:documentation
    module Documentation
      include Hacksaw::XML::Element
      
      # documentation MUST have string content
      def to_s
        content
      end
    end

    module Locator
      include Hacksaw::XLink::Locator
      
      # xlink:type MUST be "locator"
      # xlink:href is REQUIRED
      # xlink:label is REQUIRED
      
      def title_tags
        extend_children_with_qattr(NS_XL, 'type', 'title', Title)
      end
    end
    
    # defines local resources
    module Resource
      include Hacksaw::XLink::Resource
      
      # xlink:type MUST be "resource"
      # xlink:label is REQUIRED
      # xlink:role is optional.
    end
    
    # The semantics of xl:arc are **complicated**, but they're documented at:
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.3.9
    module Arc
      include Hacksaw::XLink::Arc
      
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
      def order_attr
        qattr(NS_XL, 'order').to_f
      end
      
      # The optional use attribute MUST take one of two possible values – "optional", or "prohibited".
      def use_attr
        qattr(NS_XL, 'use')
      end
      
      # The content of the priority attribute MUST be an integer.
      def priority_attr
        qattr(NS_XL, 'priority').to_i
      end
      
      def title_tags
        extend_children_with_qattr(NS_XL, 'type', 'title', Title)
      end
    end
    

    module ExtendedLink
      include Hacksaw::XLink::ExtendedLink
      
      # xlink:type MUST be "extended"
      # xlink:role MUST occur on "standard extended links"
      
      # All XBRL extended links MAY contain documentation elements.
      # The documentation elements in extended links conform to the same syntax requirements that apply 
      # to documentation elements in linkbase elements. See Section 3.5.2.3 for details.
      def documentation_tags
        extend_children_with_tag(NS_XL, 'documentation', Documentation)
      end
      
      def resource_tags
        extend_children_with_qattr(NS_XL, 'type', 'resource', Resource)
      end
    
      def locator_tags
        extend_children_with_qattr(NS_XL, 'type', 'locator', Locator)
      end
    
      def arc_tags
        extend_children_with_qattr(NS_XL, 'type', 'arc', Arc)
      end

      def title_tags
        extend_children_with_qattr(NS_XL, 'type', 'title', Title)
      end
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.1
    module SimpleLink
      include Hacksaw::XLink::SimpleLink

      # xlink_type MUST be "simple"
      # xlink_href is REQUIRED
    end
  end
end