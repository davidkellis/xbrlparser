$: << File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib")

require 'test/unit'
require 'xbrlparser'
require 'pp'

class TestInstance < Test::Unit::TestCase
  def test_xbrl_instance
    path = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'sampledata', 'adbe-20100604.xml')
    doc = XBRL::Instance.load_document(path, path)
    
    
    # assert_equal 13452, doc.root.element_tags.count
    # assert_equal 3, doc.root.substitution_groups.count
    # assert_equal 12935, doc.root.elements_in_substitution_group('item', 'http://www.xbrl.org/2003/instance').count
    # assert_equal 12935, doc.root.elements_in_substitution_group('xbrli:item').count
    # assert_equal 12935, doc.root.item_elements.count
    
    # the following is a list of 10 item (concept) names defined in us-gaap-2009-01-31.xsd
    item_names = doc.root.item_names
    ["AccidentAndHealthInsuranceSegmentMember",
     "OtherAccountsPayableAndAccruedLiabilities",
     "AccountingChangesAndErrorCorrectionsTextBlock",
     "AccountingForCertainLoansAndDebtSecuritiesAcquiredInTransferDisclosureTextBlock",
     "InitialMeasurementOfInterestsContinuedToBeHeldByTransferorWhenSecuritizedFinancialAssetsAreAccountedForAsSalePolicy",
     "InterestsContinuedToBeHeldByTransferorInFinancialAssetsThatItHasSecuritizedOrServicingAssetsOrLiabilitiesRelatingToAssetsThatItHasSecuritizedAbstract",
     "InterestsContinuedToBeHeldByTransferorInFinancialAssetsThatItHasSecuritizedOrServicingAssetsOrLiabilitiesPolicy",
     "ServicingAssetsAndServicingLiabilitiesAtFairValueValuationTechniques",
     "AccountsNotesAndLoansReceivableNetCurrent",
     "AccountsNotesAndLoansReceivableNetCurrentAbstract"].each do |name|
      assert item_names.include?(name)
    end
  end
end
