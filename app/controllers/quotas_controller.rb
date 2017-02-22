class QuotasController < ApplicationController
  include QuotasHelper

  before_action :authenticate_user!

  # GET /quota
  # GET /quota.json
  def index
    #unless signed_in?
    #  raise CanCan::AccessDenied.new("Not authorized!", :read)
    #end

    @nbSPARQLendpoints = quota_used_sparql_count(current_user)
    @maxSPARQLendpoints = current_user.quota_sparql_count

    @nbSPARQLtriples = quota_used_sparql_triples(current_user)
    @maxSPARQLtriples = current_user.quota_sparql_ktriples*1024

    @nbFilestores = quota_used_file_count(current_user)
    @maxFilestores = current_user.quota_filestore_count

    @nbFilestoresSize = quota_used_file_size(current_user)
    @maxFilestoresSize = current_user.quota_filestore_ksize*1024

    @nbTransformations = quota_used_transformations_count(current_user)
    @maxTransformations = current_user.quota_transformation_count

    respond_to do |format|
      format.html
      format.json { render template: 'quotas/index' }
    end
  end
end
