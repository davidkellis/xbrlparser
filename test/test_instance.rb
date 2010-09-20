$: << File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require 'test/unit'
require 'xbrlparser'
require 'pp'

class TestInstance < Test::Unit::TestCase
  def test_xbrl_instance
    path = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'sampledata', 'adbe-20100604.xml')
    io = LegacyExtendedIRI.new(path).open.read
    doc = XBRL::Instance.load_document(io, path)
    
    # pp doc.root.schemaRef_tags
    pp doc.root.taxonomies
    
    # assert_equal 13452, doc.root.element_tags.count
    # assert_equal 3, doc.root.substitution_groups.count
    # assert_equal 12935, doc.root.elements_in_substitution_group('item', 'http://www.xbrl.org/2003/instance').count
    # assert_equal 12935, doc.root.elements_in_substitution_group('xbrli:item').count
    # assert_equal 12935, doc.root.item_elements.count
  end
end
