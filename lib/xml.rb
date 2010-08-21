require 'nokogiri'

NS_XML = 'http://www.w3.org/XML/1998/namespace'
NS_XSD = 'http://www.w3.org/2001/XMLSchema'

module XmlDocument
  def self.extend_object(document)
    if document.is_a? Nokogiri::XML::Document
      super
    else
      raise "XmlDocument should only extend "
    end
  end
  
  def base(document_uri = nil)
    base_uri = attribute_with_ns("base", NS_XML) || url() || document_uri
    LegacyExtendedIRI.new(base_uri)
  end
end

# XmlElement should extend Nokogiri::XML::Node objects
module XmlElement
  def id
    qattr(NS_XSD, 'id')
  end
  
  # Retreives the URI associated with the xml:base attribute.
  # Documentation: http://www.w3.org/TR/xmlbase/
  # Also: http://www.w3.org/TR/2009/REC-xmlbase-20090128/
  # The value of this attribute is interpreted as a Legacy Extended IRI (LEIRI) as
  #   defined in the W3C Note "Legacy extended IRIs for XML resource identification" [LEIRI].
  # In namespace-aware XML processors, the "xml" prefix is bound to the namespace name
  #   http://www.w3.org/XML/1998/namespace as described in Namespaces in XML [XML Names].
  #
  # Returns a LegacyExtendedIRI object
  def base(document_uri = nil)
    if parent
      relative_base_uri = attribute_with_ns("base", NS_XML)
      if relative_base_uri
        parent.base(document_uri).transform_relative_reference(relative_base_uri)
      else
        parent.base(document_uri)
      end
    else
      base_uri = attribute_with_ns("base", NS_XML) || document_uri
      LegacyExtendedIRI.new(base_uri)
    end
  end
  
  # returns an array of Nokogiri::XML::Namespace objects
  def namespace_scopes
    super
  end

  # returns a hash of prefix/Nokogiri::XML::Namespace pairs
  def namespaces_by_prefix
    namespace_scopes.reduce({}, &->(m, ns) { m[ns.prefix]=ns; m })
  end

  # returns a hash of URI/Nokogiri::XML::Namespace pairs
  def namespaces_by_uri
    namespace_scopes.reduce({}, &->(m, ns) { m[ns.href]=ns; m })
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
  
  # I think this does the same thing as a call to attribute_with_ns(attribute_name, ns)
  def qattr(ns, attribute_name)
    attr_name = qname(ns, attribute_name)
    attribute = xpath("@#{attr_name}").first    # this should return a Nokogiri::XML::Attr object if the attribute exists
    attribute.value if attribute
  end
end

module XmlSchema
  include XmlElement
end