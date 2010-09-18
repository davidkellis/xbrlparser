
module XBRL
  # The contants defined below represent the namespace prefixes defined in Sec. 1.6 of the XBRL spec.
  # The names of the constants share the same name as the prefix in the XBRL specification, except that all the constants
  #   are prefixed with "NS_"
  # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_1.6
  NS_LINK = 'http://www.xbrl.org/2003/linkbase'
  NS_XBRLI = 'http://www.xbrl.org/2003/instance'
  NS_XL = 'http://www.xbrl.org/2003/XLink'
  NS_XLINK = 'http://www.w3.org/1999/xlink'
  NS_XML = 'http://www.w3.org/XML/1998/namespace'
  NS_XSI = 'http://www.w3.org/2001/XMLSchema-instance'
  NS_XSD = 'http://www.w3.org/2001/XMLSchema'

  # This class models everything between <xbrl> and </xbrl>
  module Instance
    include Hacksaw::XML::Element
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.2
    # determine the DTS that supports this XBRL Instance document
    def dts
      taxonomies + linkbases
    end
    
    def taxonomies
    end
    
    def linkbases
    end
    
    def items
      # 1. Identify taxonomies in DTS
      # 2. Enumerate element definitions in each of the taxonomies (from DTS) that belong to the xbrli:item substitution group.
      # 3. Scan this instance document for any element conforming to the element definitions identified in step 2.
      # 4. Return the list from step 3.
    end
    
    def tuples
      # 1. Identify taxonomies in DTS
      # 2. Enumerate element definitions in each of the taxonomies (from DTS) that belong to the xbrli:tuple substitution group.
      # 3. Scan this instance document for any element conforming to the element definitions identified in step 2.
      # 4. Return the list from step 3.
    end

    # schemaRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.2
    # Every XBRL instance MUST contain at least one schemaRef element. The schemaRef element is a simple link, as defined in
    # Section 3.5.1. The schemaRef element MUST occur as a child element of an xbrl element. All schemaRef elements in an XBRL
    # instance MUST occur before other children of the xbrl element, in document order.
    # ***In an XBRL instance, the schemaRef element points to a taxonomy schema that becomes part of the DTS
    # supporting that XBRL instance.***
    # The schema definition of the schemaRef element is "used to link to XBRL taxonomy schemas from XBRL instances".
    def schemaRefs
      # # xbrl_tag = qname(NS_XBRLI, 'xbrl')
      # schemaRef_tag = qname(NS_LINK, 'schemaRef')
      # # xpath("/#{xbrl_tag}/#{schemaRef_tag}")
      # xpath("./#{schemaRef_tag}")   # this works because . refers to the <xbrl> root tag
      extend_children_with_tag(NS_LINK, 'schemaRef', ::XBRL::Linkbase::SchemaRef)
    end
  
    # linkbaseRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3
    # One or more linkbaseRef elements MAY occur as children of the xbrl element (They MAY also occur in taxonomy schemas.
    # See Section 5.1.2 for details). If linkbaseRef elements occur as children of xbrl elements, they MUST follow the
    # schemaRef elements and precede all other elements, in document order.
    # The schema definition of the linkbaseRef element is "used to link to XBRL taxonomy extended links from
    #   taxonomy schema documents and from XBRL instances."
    def linkbaseRefs
      extend_children_with_tag(NS_LINK, 'linkbaseRef', ::XBRL::Linkbase::LinkbaseRef)
    end
  
    # roleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.4
    # roleRef elements are used in XBRL instances to reference the definitions of any custom xlink:role attribute
    # values used in footnote links in the XBRL instance.
    def roleRefs
      extend_children_with_tag(NS_LINK, 'roleRef', ::XBRL::Linkbase::RoleRef)
    end
    
    # arcroleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.5
    # arcroleRef elements are used in XBRL instances to reference the definitions of any custom xlink:arcrole attribute
    # values used in footnote links in the XBRL instance.
    def arcroleRef
      extend_children_with_tag(NS_LINK, 'arcroleRef', ::XBRL::Linkbase::ArcroleRef)
    end
    
    # return item_elements and tuple_elements; items first, followed by tuples
    def fact_elements
      items.to_a + tuples.to_a    # concatenate both arrays
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.6
    # Simple facts are expressed using items (and are referred to as items in this specification)
    # All elements representing single facts or business measurements defined in an XBRL taxonomy document and reported 
    #   in an XBRL instance MUST be either (a) members of the substitution group item; or, (b) members of a substitution
    #   group originally based on item. XBRL taxonomies include taxonomy schemas that contain such element definitions.
    # item elements MUST NOT be descendants of other item elements. Structural relationships necessary in an XBRL
    #   instance MUST be captured only using tuples (see Section 4.9).
    def item_elements
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.9
    # compound facts are expressed using tuples (and are referred to as tuples in this specification)
    def tuple_elements
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.7
    def contexts
      extend_children_with_tag(NS_XBRLI, 'context', Context)
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
    def units
      extend_children_with_tag(NS_XBRLI, 'unit', Unit)
    end
    
    # footnoteLink elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.11.1
    def footnoteLinks
      extend_children_with_tag(NS_XBRLI, 'footnoteLink', ::XBRL::Linkbase::FootnoteLink)
    end
  end
  
  module Item
    include Hacksaw::XML::Element
  end
  
  module Tuple
    include Hacksaw::XML::Element
  end
  
  # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.7
  module Context
    include Hacksaw::XML::Element
    
    # xml:id is REQUIRED (MUST conform to the ID type specification: http://www.w3.org/TR/REC-xml#NT-TokenizedType)
    # xbrli:entity is REQUIRED
    # xbrli:period is REQUIRED
    # xbrli:scenario is optional
    
    def entity
      tag = qname(NS_XBRLI, 'entity')
      xpath("./#{tag}").first.extend(Entity)
    end
    
    def period
      tag = qname(NS_XBRLI, 'period')
      xpath("./#{tag}").first.extend(Period)
    end
    
    def scenarios
      extend_children_with_tag(NS_XBRLI, 'scenario', Scenario)
    end
  end
  
  module Entity
    include Hacksaw::XML::Element
    
    def identifier
      tag = qname(NS_XBRLI, 'identifier')
      xpath("./#{tag}").first.extend(EntityIdentifier)
    end
    
    # Segment elements are optional, but if they are given they MUST NOT be empty.
    def segments
      qelements(NS_XBRLI, 'segment').to_a
    end
  end
  
  module EntityIdentifier
    include Hacksaw::XML::Element
    
    # The content MUST be a token that is a valid identifier within the namespace referenced by the scheme attribute.
    # attribute 'scheme' is REQUIRED
    
    def scheme
      qattr(NS_XBRLI, 'scheme')
    end
    
    # Returns the content of the <identifier> element. The content is a TOKEN identifier.
    def to_s
      content
    end
  end
  
  module Period
    include Hacksaw::XML::Element
    
    def instant
      tag = qname(NS_XBRLI, 'instant')
      xpath("./#{tag}").first
    end
    
    def start_date
      tag = qname(NS_XBRLI, 'startDate')
      xpath("./#{tag}").first
    end
    
    def end_date
      tag = qname(NS_XBRLI, 'endDate')
      xpath("./#{tag}").first
    end
    
    def forever?
      tag = qname(NS_XBRLI, 'forever')
      !xpath("./#{tag}").first.nil?
    end
  end
  
  module Scenario
    include Hacksaw::XML::Element
    
    # The scenario element MUST NOT be empty.
  end
  
  # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
  module Unit
    include Hacksaw::XML::Element
    
    def measures
      tag = qname(NS_XBRLI, 'measure')
      xpath("./#{tag}").to_a
    end
    
    def divide
      tag = qname(NS_XBRLI, 'divide')
      xpath("./#{tag}").first
    end
  end
end
