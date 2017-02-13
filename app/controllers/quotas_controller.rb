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
    @maxSPARQLendpoints = 10

    total_sparql_triples = 0;
    users_sparql.each do |se|
      unless se.repository_size == nil
        total_sparql_triples += se.repository_size
      else
        puts "se size:"+se.inspect
      end
    end
    @nbSPARQLtriples = total_sparql_triples
    @maxSPARQLtriples = 10*1024*1024

    users_files = current_user.filestores
    @nbFilestores = users_files.count
    @maxFilestores = 100

    total_file_size = 0;
    users_files.each do |fs|
      unless fs.file == nil
        unless fs.file.size == nil
          total_file_size += fs.file.size
        else
          puts "fs size:"+fs.inspect
        end
      else
        puts "fs file:"+fs.inspect
      end
    end
    @nbFilestoresSize = total_file_size
    @maxFilestoresSize = 1024*1024*1024

    @nbTransformations = current_user.transformations.count
    @maxTransformations = 100

    respond_to do |format|
      format.html
      format.json { render template: 'quotas/index' }
    end
  end
end
