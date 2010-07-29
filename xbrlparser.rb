require 'nokogiri'
require 'pp'
require 'xlink'

NS_XML = 'http://www.w3.org/XML/1998/namespace'

def resolve_base_uri(parent_base_uri, child_base_uri)
end

def resolve_href_uri(base_uri, href_uri)
end

# XmlElement is really a wrapper around Nokogiri::XML::Node
class XmlElement
  class << self
    def load(filename)
      file_contents = File.new(filename).read
      document = Nokogiri.XML(file_contents)      # returns a Nokogiri::XML::Document
      self.new(document.root)                     # document.root returns a Nokogiri::XML::Element < Nokogiri::XML::Node
    end
  end
  
  attr_reader :parent
  
  # root_node is a Nokogiri::XML::Node object
  def initialize(root_node, parent = nil)
    @root = root_node
    @parent = parent
  end
  
  # Retreives the URI associated with the xml:base attribute.
  # Documentation: http://www.w3.org/TR/xmlbase/
  # Also: http://www.w3.org/TR/2009/REC-xmlbase-20090128/
  # The value of this attribute is interpreted as a Legacy Extended IRI (LEIRI) as
  #   defined in the W3C Note "Legacy extended IRIs for XML resource identification" [LEIRI].
  # In namespace-aware XML processors, the "xml" prefix is bound to the namespace name
  #   http://www.w3.org/XML/1998/namespace as described in Namespaces in XML [XML Names].
  def base
    @base ||= if parent
                resolve_base_uri(parent.base, @root.attribute_with_ns("base", NS_XML))
              else
                @root.attribute_with_ns("base", NS_XML)
              end
  end
  
  # returns an array of Nokogiri::XML::Namespace objects
  def namespaces
    @namespaces ||= @root.namespace_scopes()
  end

  # returns a hash of prefix/Nokogiri::XML::Namespace pairs
  def namespaces_by_prefix
    @namespaces_by_prefix ||= namespaces.reduce({}, &->(m, ns) { m[ns.prefix]=ns; m })
  end

  # returns a hash of URI/Nokogiri::XML::Namespace pairs
  def namespaces_by_uri
    @namespaces_by_uri ||= namespaces.reduce({}, &->(m, ns) { m[ns.href]=ns; m })
  end

  # returns the prefix of the namespace referenced by the given URI
  # returns nil if none of the namespaces reference the given URI
  def prefix_for(ns_uri)
    if namespaces_by_uri().has_key?(ns_uri)
      namespaces_by_uri()[ns_uri].prefix || ""       # namespace.prefix returns nil if there is no prefix defined (default prefix)
    end
  end

  # construct the namespace-prefix-qualified name given the document's namespaces
  def qname(ns_uri, name)
    prefix = prefix_for(ns_uri)
    raise "Namespace at URI=#{ns_uri} not referenced!" if prefix.nil?
    if prefix.empty?
      "#{name}"
    else
      "#{prefix}:#{name}"
    end
  end
  
  def get_qualified_attr(ns, attribute_name)
    attr_name = qname(ns, attribute_name)
    attribute = @root.xpath("@#{attr_name}").first    # this should return a Nokogiri::XML::Attr object if the attribute exists
    attribute.value if attribute
  end
end

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

  class Taxonomy < XmlElement
    def dts
    end
  end

  class Linkbase < XmlElement
    class RoleRef < ::XBRL::XLink::SimpleLink
      # xlink:type MUST be "simple"
      # xlink:href is REQUIRED
      # link:roleURI is REQUIRED
      
      def roleURI           # The roleURI attribute MUST occur on the roleRef element.
        @roleURI ||= get_qualified_attr(NS_LINK, 'roleURI')
      end
    end
    
    class ArcroleRef < ::XBRL::XLink::SimpleLink
      # xlink:type MUST be "simple"
      # xlink:href is REQUIRED
      # link:arcroleURI is REQUIRED
      
      def arcroleURI
        @arcroleURI ||= get_qualified_attr(NS_LINK, 'arcroleURI')
      end
    end
    
    def dts
    end
    
    def roleRefs
      @roleRefs ||= roleRef_elements.to_a.map {|n| RoleRef.new(n, self) }
    end

    def arcroleRefs
      @arcroleRefs ||= arcroleRef_elements.to_a.map {|n| ArcroleRef.new(n, self) }
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
        attr_name = qname(NS_XLINK, 'type')
        @extended_type_elements = @root.xpath("*[@#{attr_name}='extended']")
      end
      @extended_type_elements
    end
  end

  class Instance < XmlElement
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
    
    # schemaRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.2
    # Every XBRL instance MUST contain at least one schemaRef element. The schemaRef element is a simple link, as defined in
    # Section 3.5.1. The schemaRef element MUST occur as a child element of an xbrl element. All schemaRef elements in an XBRL
    # instance MUST occur before other children of the xbrl element, in document order.
    # ***In an XBRL instance, the schemaRef element points to a taxonomy schema that becomes part of the DTS
    # supporting that XBRL instance.***
    # The schema definition of the schemaRef element is "used to link to XBRL taxonomy schemas from XBRL instances".
    def schemaRef_elements
      unless @schemaRef_elements
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        schemaRef_tag = qname(NS_LINK, 'schemaRef')
        #@schemaRef_elements = @root.xpath("/#{xbrl_tag}/#{schemaRef_tag}")
        @schemaRef_elements = @root.xpath("./#{schemaRef_tag}")   # this works because . refers to the <xbrl> root tag
      end
      @schemaRef_elements
    end
  
    # linkbaseRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.3
    # One or more linkbaseRef elements MAY occur as children of the xbrl element (They MAY also occur in taxonomy schemas.
    # See Section 5.1.2 for details). If linkbaseRef elements occur as children of xbrl elements, they MUST follow the
    # schemaRef elements and precede all other elements, in document order.
    # The schema definition of the linkbaseRef element is "used to link to XBRL taxonomy extended links from
    #   taxonomy schema documents and from XBRL instances."
    def linkbaseRef_elements
      unless @linkbaseRef_elements
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        linkbaseRef_tag = qname(NS_LINK, 'linkbaseRef')
        @linkbaseRef_elements = @root.xpath("/#{xbrl_tag}/#{linkbaseRef_tag}")
      end
      @linkbaseRef_elements
    end
  
    # roleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.4
    # roleRef elements are used in XBRL instances to reference the definitions of any custom xlink:role attribute
    # values used in footnote links in the XBRL instance.
    def roleRef_elements
      unless @roleRef_elements
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        roleRef_tag = qname(NS_LINK, 'roleRef')
        @roleRef_elements = @root.xpath("/#{xbrl_tag}/#{roleRef_tag}")
      end
      @roleRef_elements
    end
  
    # arcroleRef elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.5
    # arcroleRef elements are used in XBRL instances to reference the definitions of any custom xlink:arcrole attribute
    # values used in footnote links in the XBRL instance.
    def arcroleRef_elements
      unless @arcroleRef_elements
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        arcroleRef_tag = qname(NS_LINK, 'arcroleRef')
        @arcroleRef_elements = @root.xpath("/#{xbrl_tag}/#{arcroleRef_tag}")
      end
      @arcroleRef_elements
    end
  
    # return items and tuples; items first, followed by tuples
    def facts
      @facts ||= items + tuples    # concatenate both arrays
    end
  
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.6
    # Simple facts are expressed using items (and are referred to as items in this specification)
    # All elements representing single facts or business measurements defined in an XBRL taxonomy document and reported 
    #   in an XBRL instance MUST be either (a) members of the substitution group item; or, (b) members of a substitution
    #   group originally based on item. XBRL taxonomies include taxonomy schemas that contain such element definitions.
    # item elements MUST NOT be descendants of other item elements. Structural relationships necessary in an XBRL
    #   instance MUST be captured only using tuples (see Section 4.9).
    def items
    end
  
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.9
    # compound facts are expressed using tuples (and are referred to as tuples in this specification)
    def tuples
    end
  
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.7
    def contexts
      unless @contexts
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        context_tag = qname(NS_XBRLI, 'context')
        @contexts = @root.xpath("/#{xbrl_tag}/#{context_tag}")
      end
      @contexts
    end
  
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.8
    def units
      unless @units
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        unit_tag = qname(NS_XBRLI, 'unit')
        @units = @root.xpath("/#{xbrl_tag}/#{unit_tag}")
      end
      @units
    end
  
    # footnoteLink elements
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_4.11
    def footnoteLink_elements
      unless @footnoteLink_elements
        xbrl_tag = qname(NS_XBRLI, 'xbrl')
        footnoteLink_tag = qname(NS_LINK, 'footnoteLink')
        @footnoteLink_elements = @root.xpath("/#{xbrl_tag}/#{footnoteLink_tag}")
      end
      @footnoteLink_elements
    end
  end
  
  class SchemaRef < XmlElement
    def type
      @root.attribute_with_ns("type", NS_XLINK)
    end
    
    # 4.2.2 - The xlink:href attribute on schemaRef elements
    # A schemaRef element MUST have an xlink:href attribute. The xlink:href attribute MUST be a URI.
    # The URI MUST point to an XML Schema. If the URI reference is relative, its absolute version MUST be determined as
    # specified in [XML Base] before use. For details on the allowable forms of XPointer [XPTR] syntax in the URI see
    # section 3.5.4.
    def href
      @root.attribute_with_ns("href", NS_XLINK)
    end
    
    def absolute_href
    end
  end

  class Item < XmlElement
  end

  class Tuple < XmlElement
  end
end

def main
  f = ARGV[0]
  
  instance = XBRL::Instance.load(f)
  pp instance.schemaRef_elements
  # instance.facts.each do |fact|
  #   puts fact
  # end
end

main if $0 == __FILE__