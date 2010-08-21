$: << File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require "xbrl"
require "pp"

def main
  f = ARGV[0]
  
  instance_doc = XBRL::Instance.load(f, File.absolute_path(f))
  pp instance_doc.root.namespace_scopes
  pp instance_doc.root.namespaces_by_prefix
  pp instance_doc.root.base
  pp instance_doc.root.schemaRef_elements
  # instance.facts.each do |fact|
  #   puts fact
  # end
end

main