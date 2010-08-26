require 'nokogiri'
require 'xml'
require 'xlink'
require 'xbrl_linkbase'
require 'xbrl_xlink'
require 'leiri'

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
    include XmlElement
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_3.2
    # determine the DTS that supports this XBRL Instance document
    def dts
      taxonomies + linkbases
    end
    
    def taxonomies
      schemaRef_elements
    end
    
    def linkbases
      linkbaseRef_elements
    end
    
    def items
    end
    
    def tuples
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
      qelements(NS_LINK, 'schemaRef').to_a.map {|n| n.extend ::XBRL::Linkbase::SchemaRef }
    end
  
    # linkbaseRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3
    # One or more linkbaseRef elements MAY occur as children of the xbrl element (They MAY also occur in taxonomy schemas.
    # See Section 5.1.2 for details). If linkbaseRef elements occur as children of xbrl elements, they MUST follow the
    # schemaRef elements and precede all other elements, in document order.
    # The schema definition of the linkbaseRef element is "used to link to XBRL taxonomy extended links from
    #   taxonomy schema documents and from XBRL instances."
    def linkbaseRefs
      qelements(NS_LINK, 'linkbaseRef').to_a.map {|n| n.extend ::XBRL::Linkbase::LinkbaseRef }
    end
  
    # roleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.4
    # roleRef elements are used in XBRL instances to reference the definitions of any custom xlink:role attribute
    # values used in footnote links in the XBRL instance.
    def roleRefs
      qelements(NS_LINK, 'roleRef').to_a.map {|n| n.extend ::XBRL::Linkbase::RoleRef }
    end
    
    # arcroleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.5
    # arcroleRef elements are used in XBRL instances to reference the definitions of any custom xlink:arcrole attribute
    # values used in footnote links in the XBRL instance.
    def arcroleRef
      qelements(NS_LINK, 'arcroleRef').to_a.map {|n| n.extend ::XBRL::Linkbase::ArcroleRef }
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
      qelements(NS_XBRLI, 'context').to_a.map {|n| n.extend(Context) }
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
    def units
      qelements(NS_XBRLI, 'unit').to_a.map {|n| n.extend(Unit) }
    end
    
    # footnoteLink elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.11
    def footnoteLinks
      qelements(NS_XBRLI, 'footnoteLink').to_a.map {|n| n.extend(FootnoteLink) }
    end
  end
  
  module Item
    include XmlElement
  end
  
  module Tuple
    include XmlElement
  end
  
  # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.7
  module Context
    include XmlElement
    
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
      tag = qname(NS_XBRLI, 'scenario')
      xpath("./#{tag}").to_a.map {|n| n.extend(Scenario) }
    end
  end
  
  module Entity
    include XmlElement
    
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
    include XmlElement
    
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
    include XmlElement
    
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
    include XmlElement
    
    # The scenario element MUST NOT be empty.
  end
  
  # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
  module Unit
    include XmlElement
    
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
