require 'test_helper'

class SparqlEndpointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "should not save without valid properties (name)" do
    se = SparqlEndpoint.new
    assert_not se.save, "Saved the sparql endpoint without valid properties (name)"
  end
  
end
