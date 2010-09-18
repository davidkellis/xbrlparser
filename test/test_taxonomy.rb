$: << File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require 'test/unit'
require 'xbrlparser'
require 'pp'

class TestTaxonomy < Test::Unit::TestCase
  def test_taxonomy_schema
    path = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'schema', 'us-gaap-2009-01-31.xsd')
    doc = XBRL::Taxonomy.load_document(path, path)
    
    # pp doc.root.substitution_groups
    # pp doc.root.elements_in_substitution_group('item', 'http://www.xbrl.org/2003/instance').count
    pp doc.root.tuple_elements
    
    assert_equal 13452, doc.root.element_tags.count
    assert_equal 3, doc.root.substitution_groups.count
    assert_equal 12935, doc.root.elements_in_substitution_group('item', 'http://www.xbrl.org/2003/instance').count
    assert_equal 12935, doc.root.elements_in_substitution_group('xbrli:item').count
    assert_equal 12935, doc.root.item_elements.count
  end
end