$: << File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require "xbrl"
require "pp"

def main
  f = ARGV[0]
  
  taxonomy_doc = XBRL::Taxonomy.load_document(f, File.absolute_path(f))
  pp taxonomy_doc.root.namespace_scopes
end

main