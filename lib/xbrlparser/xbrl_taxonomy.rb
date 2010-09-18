
module XBRL
  module Taxonomy
    include Hacksaw::XML::Schema
    
    def concepts
      item_elements | tuple_elements
    end
    
    def item_elements
      elements_in_substitution_group('item', 'http://www.xbrl.org/2003/instance')
    end
    
    def tuple_elements
      elements_in_substitution_group('tuple', 'http://www.xbrl.org/2003/instance')
    end
  end
end