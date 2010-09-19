
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
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.3
    module RoleType
      include Hacksaw::XML::Element

      # The roleURI attribute MUST occur and MUST contain the role value being defined. 
      # When the custom role type is used, the xlink:role attribute value matches the value of the roleURI.
      def roleURI_attr
        attr('roleURI')
      end
      
      def definition_tags
        extend_children_with_tag(NS_LINK, 'definition', Definition)
      end

      def usedOn_tags
        extend_children_with_tag(NS_LINK, 'usedOn', UsedOn)
      end
    end
    
    module Definition
      include Hacksaw::XML::Element
      
      # The content of a definition element MUST be a string giving meaning to the role type.
      def to_s
        content
      end
    end
    
    # The roleType element MAY contain one or more usedOn elements.
    # The usedOn element identifies which elements MAY use the role type being defined.
    module UsedOn
      include Hacksaw::XML::Element

      # The usedOn element has a type of QName, so it must be some form of qualified or unqualified name.
      def to_s
        content
      end
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.4
    module ArcroleType
      include Hacksaw::XML::Element
      
      # The arcroleURI attribute MUST occur and MUST contain the arc role value being defined.
      # When the defined arc role type is used, the xlink:arcrole attribute value matches the value of the arcroleURI.
      def arcroleURI_attr
        attr('arcroleURI')
      end
      
      # The arcroleType element MUST have a cyclesAllowed attribute that identifies the type of cycles
      # that are allowed in a network of relationships as defined in Section 3.5.3.9.7.3.
      def cyclesAllowed_attr
        attr('cyclesAllowed')
      end
      
      # The arcroleType element MAY contain a definition element.
      # The definition element MUST contain a string giving human-readable meaning to the arc role type.
      def definition_tags
        extend_children_with_tag(NS_LINK, 'definition', Definition)
      end

      # The arcroleType element MAY contain one or more usedOn elements.
      def usedOn_tags
        extend_children_with_tag(NS_LINK, 'usedOn', UsedOn)
      end
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.2.2
    module LabelLink
      include XBRL::XLink::ExtendedLink
      
      def title_tags
        extend_children_with_qattr(NS_XL, 'type', 'title', Title)
      end

      def documentation_tags
        extend_children_with_tag(NS_LINK, 'documentation', Documentation)
      end
    
      def loc_tags
        extend_children_with_tag(NS_LINK, 'loc', Loc)
      end
  
      def labelArc_tags
        extend_children_with_tag(NS_LINK, 'labelArc', LabelArc)
      end
      
      def label_tags
        extend_children_with_tag(NS_LINK, 'label', Label)
      end
    end

    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.5.3.7
    module Loc
      include XBRL::XLink::Locator
    end

    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.2.2.2
    module Label
      include XBRL::XLink::Resource
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.2.2.3
    module LabelArc
      include XBRL::XLink::Arc
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.2.3
    module ReferenceLink
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
      def roleURI_attr
        attr('roleURI')
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
      def arcroleURI_attr
        attr('arcroleURI')
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
  
    def documentation_tags
      extend_children_with_tag(NS_LINK, 'documentation', Documentation)
    end
  
    def roleRef_tags
      extend_children_with_tag(NS_LINK, 'roleRef', RoleRef)
    end

    def arcroleRef_tags
      extend_children_with_tag(NS_LINK, 'arcroleRef', ArcroleRef)
    end
    
    def extended_link_tags
      elements_in_substitution_group('extended', NS_LINK)
      # extend_children_with_qattr(NS_XL, 'type', 'extended', ::XBRL::XLink::ExtendedLink)
    end
  end
end