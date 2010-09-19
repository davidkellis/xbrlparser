
module XBRL
  module Taxonomy
    include Hacksaw::XML::Schema
    
    NS_US_GAAP_2009 = "http://xbrl.us/us-gaap/2009-01-31"
    
    module TaxonomyElement
      include Hacksaw::XML::SchemaElement
      
      # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.1.1
      # The periodType attribute MUST be used on elements in the substitution group for the item element.
      def periodType_attr
        qattr(NS_XBRLI, 'periodType')
      end
      
      # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.1.2
      def balance_attr
        qattr(NS_XBRLI, 'balance')
      end
    end
    
    # The linkbaseRef element MAY be placed among the set of nodes identified by
    # the XPath [XPATH] path "//xsd:schema/xsd:annotation/xsd:appinfo/*" in a taxonomy schema.
    def linkbaseRef_tags
      attribute_tags.map do |attr_tag|
        attr_tag.annotation_tags.map do |anno_tag|
          anno_tag.appInfo_tags.map do |appinfo|
            appinfo.extend_children_with_tag(NS_LINK, 'linkbaseRef', ::XBRL::Linkbase::LinkbaseRef)
          end
        end
      end.flatten
    end
    
    def linkbase_tags
      attribute_tags.map do |attr_tag|
        attr_tag.annotation_tags.map do |anno_tag|
          anno_tag.appInfo_tags.map do |appinfo|
            appinfo.extend_children_with_tag(NS_LINK, 'linkbase', ::XBRL::Linkbase)
          end
        end
      end.flatten
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.3
    def roleType_tags
      attribute_tags.map do |attr_tag|
        attr_tag.annotation_tags.map do |anno_tag|
          anno_tag.appInfo_tags.map do |appinfo|
            appinfo.extend_children_with_tag(NS_LINK, 'roleType', ::XBRL::Linkbase::RoleType)
          end
        end
      end.flatten
    end
    
    # http://www.xbrl.org/Specification/XBRL-RECOMMENDATION-2003-12-31+Corrected-Errata-2008-07-02.htm#_5.1.4
    # The arcroleType element MUST be among the set of nodes identified by
    # the [XPATH] path "//xsd:schema/xsd:annotation/xsd:appinfo/*”.
    def arcroleType_tags
      attribute_tags.map do |attr_tag|
        attr_tag.annotation_tags.map do |anno_tag|
          anno_tag.appInfo_tags.map do |appinfo|
            appinfo.extend_children_with_tag(NS_LINK, 'arcroleType', ::XBRL::Linkbase::ArcroleType)
          end
        end
      end.flatten
    end
    
    def element_tags
      extend_children_with_tag(NS_XSD, 'element', TaxonomyElement)
    end
    
    def concept_elements
      item_elements | tuple_elements
    end
    
    def item_names
      item_elements.map {|n| n.attr('name') }
    end
    
    def tuple_names
      tuple_elements.map {|n| n.attr('name') }
    end

    def item_elements
      elements_in_substitution_group('item', NS_XBRLI)
    end
    
    def tuple_elements
      elements_in_substitution_group('tuple', NS_XBRLI)
    end
  end
end