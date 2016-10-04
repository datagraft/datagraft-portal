class SparqlEndpointQuery < ApplicationRecord
  belongs_to :query
  belongs_to :sparql_endpoint
end
