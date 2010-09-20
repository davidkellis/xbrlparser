
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
    # Determine the taxonomy schemas in the DTS.
    def dts_taxonomies
      direct_taxonomies = taxonomies()
      
      import_and_include_leiris = direct_taxonomies.map do |tax|
        tax.import_tags.map {|imp| imp.schema_location_uri } + tax.include_tags.map {|inc| inc.schema_location_uri }
      end
      
      imported_or_included_taxonomies = import_and_include_leiris.map {|leiri| XBRL::Taxonomy.load_document(leiri.read, leiri.to_s) }
    end
    
    # Determine the linkbase documents in the DTS.
    def dts_linkbases
    end
    
    # Taxonomy schemas in the DTS are those:
    # 1. referenced directly from an XBRL instance using the schemaRef, roleRef, arcroleRef or linkbaseRef element.
    #    The xlink:href attribute on the schemaRef, roleRef, arcroleRef or linkbaseRef element contains the URL of 
    #    the taxonomy schema that is discovered. Every taxonomy schema that is referenced by the schemaRef, roleRef,
    #    arcroleRef or linkbaseRef element MUST be discovered.
    #
    # NOTE (DKE): I believe the preceeding description is incorrect. linkbaseRef elements are supposed to reference
    #             a linkbase document. http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3.2
    #             says "A linkbaseRef element MUST have an xlink:href attribute. The xlink:href attribute MUST be a URI. 
    #             The URI MUST point to a linkbase (as defined in Section 3.5.2)..."
    #
    # This method only returns the taxonomies that are directly linked to from this instance document.
    def taxonomies
      schema_leiris = (schemaRef_tags + roleRef_tags + arcroleRef_tags).map{|n| n.xlink_href }
      schema_leiris.map do |leiri|
        doc = leiri.read
        XBRL::Taxonomy.load_document(doc, leiri.to_s)
      end
    end
    
    # Linkbase documents in the DTS are those:
    # 1. referenced directly from an XBRL instance via the linkbaseRef element.
    #    The xlink:href attribute contains the URL of the linkbase document being discovered. Every linkbase that is
    #    referenced by the linkbaseRef element MUST be discovered.
    #
    # This method only returns the linkbases that are directly linked to from this instance document.
    def linkbases
      linkbase_leiris = linkbaseRef_tags.map{|n| n.xlink_href }
      linkbase_leiris.map do |leiri|
        doc = leiri.read
        XBRL::Linkbase.load_document(doc, leiri.to_s)
      end
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
    def schemaRef_tags
      extend_children_with_tag(NS_LINK, 'schemaRef', ::XBRL::Linkbase::SchemaRef)
    end

    # linkbaseRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3
    # One or more linkbaseRef elements MAY occur as children of the xbrl element (They MAY also occur in taxonomy schemas.
    # See Section 5.1.2 for details). If linkbaseRef elements occur as children of xbrl elements, they MUST follow the
    # schemaRef elements and precede all other elements, in document order.
    # The schema definition of the linkbaseRef element is "used to link to XBRL taxonomy extended links from
    #   taxonomy schema documents and from XBRL instances."
    def linkbaseRef_tags
      extend_children_with_tag(NS_LINK, 'linkbaseRef', ::XBRL::Linkbase::LinkbaseRef)
    end

    # roleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.4
    # roleRef elements are used in XBRL instances to reference the definitions of any custom xlink:role attribute
    # values used in footnote links in the XBRL instance.
    def roleRef_tags
      extend_children_with_tag(NS_LINK, 'roleRef', ::XBRL::Linkbase::RoleRef)
    end

    # arcroleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.5
    # arcroleRef elements are used in XBRL instances to reference the definitions of any custom xlink:arcrole attribute
    # values used in footnote links in the XBRL instance.
    def arcroleRef_tags
      extend_children_with_tag(NS_LINK, 'arcroleRef', ::XBRL::Linkbase::ArcroleRef)
    end
    
    # return item_elements and tuple_elements; items first, followed by tuples
    def fact_tags
      items.to_a + tuples.to_a    # concatenate both arrays
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.6
    # Simple facts are expressed using items (and are referred to as items in this specification)
    # All elements representing single facts or business measurements defined in an XBRL taxonomy document and reported 
    #   in an XBRL instance MUST be either (a) members of the substitution group item; or, (b) members of a substitution
    #   group originally based on item. XBRL taxonomies include taxonomy schemas that contain such element definitions.
    # item elements MUST NOT be descendants of other item elements. Structural relationships necessary in an XBRL
    #   instance MUST be captured only using tuples (see Section 4.9).
    def item_tags
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.9
    # compound facts are expressed using tuples (and are referred to as tuples in this specification)
    def tuple_tags
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.7
    def context_tags
      extend_children_with_tag(NS_XBRLI, 'context', Context)
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
    def unit_tags
      extend_children_with_tag(NS_XBRLI, 'unit', Unit)
    end
    
    # footnoteLink elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.11.1
    def footnoteLink_tags
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
    
    def entity_tag
      tag = qname(NS_XBRLI, 'entity')
      xpath("./#{tag}").first.extend(Entity)
    end
    
    def period_tags
      tag = qname(NS_XBRLI, 'period')
      xpath("./#{tag}").first.extend(Period)
    end
    
    def scenario_tags
      extend_children_with_tag(NS_XBRLI, 'scenario', Scenario)
    end
  end
  
  module Entity
    include Hacksaw::XML::Element
    
    def identifier_tag
      tag = qname(NS_XBRLI, 'identifier')
      xpath("./#{tag}").first.extend(EntityIdentifier)
    end
    
    # Segment elements are optional, but if they are given they MUST NOT be empty.
    def segment_tags
      qelements(NS_XBRLI, 'segment').to_a
    end
  end
  
  module EntityIdentifier
    include Hacksaw::XML::Element
    
    # The content MUST be a token that is a valid identifier within the namespace referenced by the scheme attribute.
    # attribute 'scheme' is REQUIRED
    
    def scheme_attr
      qattr(NS_XBRLI, 'scheme')
    end
    
    # Returns the content of the <identifier> element. The content is a TOKEN identifier.
    def to_s
      content
    end
  end
  
  module Period
    include Hacksaw::XML::Element
    
    def instant_tag
      tag = qname(NS_XBRLI, 'instant')
      xpath("./#{tag}").first
    end
    
    def startDate_tag
      tag = qname(NS_XBRLI, 'startDate')
      xpath("./#{tag}").first
    end
    
    def endDate_tag
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
    
    def measure_tags
      tag = qname(NS_XBRLI, 'measure')
      xpath("./#{tag}").to_a
    end
    
    def divide_tag
      tag = qname(NS_XBRLI, 'divide')
      xpath("./#{tag}").first
    end
  end
end
