require 'xbrlparser'
require 'xlink'
require 'xbrl_xlink'

module XBRL
  class Linkbase < XmlElement
    class Documentation < XmlElement
      # documentation MUST have string content
      def to_s
        node.content
      end
    end
    
    class RoleRef < ::XBRL::XLink::SimpleLink
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
        @roleURI ||= get_qualified_attr(NS_LINK, 'roleURI')
      end
    end
  
    class ArcroleRef < ::XBRL::XLink::SimpleLink
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
        @arcroleURI ||= get_qualified_attr(NS_LINK, 'arcroleURI')
      end
    end
  
    def dts
    end
  
    def documentation
      @documentation ||= documentation_elements.to_a.map {|n| Documentation.new(n, self) }
    end
  
    def roleRefs
      @roleRefs ||= roleRef_elements.to_a.map {|n| RoleRef.new(n, self) }
    end

    def arcroleRefs
      @arcroleRefs ||= arcroleRef_elements.to_a.map {|n| ArcroleRef.new(n, self) }
    end
    
    def extended_links
      @extended_links ||= extended_type_elements.to_a.map {|n| XBRL::XLink::ExtendedLink.new(n, self) }
    end
  
    def documentation_elements
      unless @documentation_elements
        documentation_tag = qname(NS_LINK, 'documentation')
        @documentation_elements = @root.xpath("./#{documentation_tag}")   # this works because . refers to the <linkbase> root tag
      end
      @documentation_elements
    end
  
    def roleRef_elements
      unless @roleRef_elements
        roleRef_tag = qname(NS_LINK, 'roleRef')
        @roleRef_elements = @root.xpath("./#{roleRef_tag}")
      end
      @roleRef_elements
    end
  
    def arcroleRef_elements
      unless @arcroleRef_elements
        arcroleRef_tag = qname(NS_LINK, 'arcroleRef')
        @arcroleRef_elements = @root.xpath("./#{arcroleRef_tag}")
      end
      @arcroleRef_elements
    end
  
    def extended_type_elements
      unless @extended_type_elements
        attr_name = qname(NS_XL, 'type')
        @extended_type_elements = @root.xpath("*[@#{attr_name}='extended']")
      end
      @extended_type_elements
    end
  end
end