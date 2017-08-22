class QuotasController < ApplicationController
  include QuotasHelper
  include DbmsHelper

  before_action :authenticate_user!

  # GET /quota
  # GET /quota.json
  def index
    #unless signed_in?
    #  raise CanCan::AccessDenied.new("Not authorized!", :read)
    #end

    #@nbOldSPARQLendpoints = quota_used_sparql_count(current_user)
    #@maxOldSPARQLendpoints = current_user.quota_sparql_count

    triple_info_hash = quota_used_sparql_triples(current_user)
    #@nbOldSPARQLtriples = triple_info_hash[:repo_triples] + triple_info_hash[:cached_triples]
    #@maxOldSPARQLtriples = current_user.quota_sparql_ktriples*1024

    @SPARQLdbArr = []

    entry = {name: "#{dbms_descriptive_name(nil)} endpoints",
             nb_ep: quota_used_sparql_count(current_user),
             max_ep: current_user.quota_sparql_count,
             nb_triples: triple_info_hash[:repo_triples] + triple_info_hash[:cached_triples],
             max_triples: current_user.quota_sparql_ktriples*1024}
    @SPARQLdbArr << entry
    @nbSPARQLcached = triple_info_hash[:cached_req]


    rdf_dbms = current_user.search_for_existing_dbms('RDF')
    rdf_dbms.each do |dbm|
      triple_info_hash = quota_used_sparql_triples(current_user, dbm)
      entry = {name: "#{dbms_descriptive_name(dbm)} endpoints",
               nb_ep: quota_used_sparql_count(current_user, dbm),
               max_ep: dbm.quota_sparql_count,
               nb_triples: triple_info_hash[:repo_triples] + triple_info_hash[:cached_triples],
               max_triples: dbm.quota_sparql_ktriples*1024}
      @SPARQLdbArr << entry
      @nbSPARQLcached += triple_info_hash[:cached_req]
    end

    if @nbSPARQLcached != 0
      flash[:error] = "#{@nbSPARQLcached} unreachable SPARQL endpoints, using last known size of triples. <br>"
    end


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
