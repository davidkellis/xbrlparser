
module XBRL
  module Linkbase
    include Hacksaw::XML::Element
    
    module Documentation
      include Hacksaw::XML::Element
      
      # documentation MUST have string content
      def to_s
        content
      end
    end
    
    module RoleRef
      include ::XBRL::XLink::SimpleLink
      
      # xlink:type MUST be "simple"
      # xlink:href is REQUIRED; it MUST be a URI and MUST point to a roleType element in a taxonomy schema document.
      # link:roleURI is REQUIRED
      # other fields have no semantics and are therefore ignored
      
      # The roleURI attribute MUST occur on the roleRef element. The roleURI attribute identifies the 
      # xlink:role attribute value that is defined by the XML resource that is pointed to by the roleRef
      # element. The value of this attribute MUST match the value of the roleURI attribute on the
      # roleType element that the roleRef element is pointing to.  Within a linkbase or an XBRL 
      # instance there MUST NOT be more than one roleRef element with the same roleURI attribute value.
      def roleURI
        qattr(NS_LINK, 'roleURI')
      end
    end
  
    module ArcroleRef
      include ::XBRL::XLink::SimpleLink
      
      # xlink:type MUST be "simple"
      # xlink:href is REQUIRED; it MUST be a URI and MUST point to an arcroleType element in a taxonomy schema document.
      # link:arcroleURI is REQUIRED
      # other fields have no semantics and are therefore ignored
    
      # The arcroleURI attribute MUST occur on the arcroleRef element. The arcroleURI attribute 
      # identifies the xlink:arcrole attribute value that is defined by the XML resource that 
      # is pointed to by the arcroleRef element. The value of this attribute MUST match the value 
      # of the arcroleURI attribute on the arcroleType element that the arcroleRef element is 
      # pointing to.  Within a linkbase or an XBRL instance there MUST NOT be more than one arcroleRef 
      # element with the same arcroleURI attribute value.
      def arcroleURI
        qattr(NS_LINK, 'arcroleURI')
      end
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.2
    module SchemaRef
      include ::XBRL::XLink::SimpleLink
      # xlink:type is REQUIRED
      # xlink:href is REQUIRED and must be a URI that points to an XML Schema.
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3
    module LinkbaseRef
      include ::XBRL::XLink::SimpleLink
      # xlink:type is REQUIRED
      # xlink:href is REQUIRED and must be a URI that points to an XML Schema.
      # xlink:arcrole is REQUIRED and MUST be 'http://www.w3.org/1999/xlink/properties/linkbase'
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.11.1
    module FootnoteLink
      include ::XBRL::XLink::ExtendedLink
    end
  
    def dts
    end
  
    def documentation
      extend_children_with_tag(NS_LINK, 'documentation', Documentation)
    end
  
    def roleRefs
      extend_children_with_tag(NS_LINK, 'roleRef', RoleRef)
    end

    def arcroleRefs
      extend_children_with_tag(NS_LINK, 'arcroleRef', ArcroleRef)
    end
    
    def extended_links
      extend_children_with_attr(NS_XL, 'type', 'extended', ::XBRL::XLink::ExtendedLink)
    end
  end
end