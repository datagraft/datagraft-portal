class QuotasController < ApplicationController
  before_action :authenticate_user!

  # GET /quota
  # GET /quota.json
  def index
    #unless signed_in?
    #  raise CanCan::AccessDenied.new("Not authorized!", :read)
    #end

    users_sparql = current_user.sparql_endpoints
    @nbSPARQLendpoints = users_sparql.count
    @maxSPARQLendpoints = current_user.quota_sparql_count

    total_sparql_triples = 0;
    users_sparql.each do |se|
      unless se.repository_size == nil
        total_sparql_triples += se.repository_size
      else
        puts "Sparql_endpoint is missing size information:"+se.inspect
      end
    end
    @nbSPARQLtriples = total_sparql_triples
    @maxSPARQLtriples = current_user.quota_sparql_ktriples*1024

    users_files = current_user.filestores
    @nbFilestores = users_files.count
    @maxFilestores = current_user.quota_filestore_count

    total_file_size = 0;
    users_files.each do |fs|
      unless fs.file == nil
        unless fs.file_size == nil
          total_file_size += fs.file_size
        else
          puts "Filestore is missing size information:"+fs.inspect
        end
      else
        puts "Filestore is missing file object:"+fs.inspect
      end
    end
    @nbFilestoresSize = total_file_size
    @maxFilestoresSize = current_user.quota_filestore_ksize*1024

    @nbTransformations = current_user.transformations.count
    @maxTransformations = current_user.quota_transformation_count

    respond_to do |format|
      format.html
      format.json { render template: 'quotas/index' }
    end
  end
end
