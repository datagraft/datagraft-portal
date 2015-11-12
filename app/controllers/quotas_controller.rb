class QuotasController < ApplicationController
  before_filter :authenticate_user!

  # GET /quota
  # GET /quota.json
  def index
    #unless signed_in?
    #  raise CanCan::AccessDenied.new("Not authorized!", :read)
    #end

    @nbDataDistributions = current_user.data_distributions.sum(:file_size)
    @maxDataDistributions = 1024*1024*1024*4

    @nbDataPages = current_user.data_pages.count
    @maxDataPages = 100

    @nbTransformations = current_user.transformations.count
    @maxTransformations = 1000
  end
end
