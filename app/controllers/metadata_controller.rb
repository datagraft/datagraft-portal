class MetadataController < ApplicationController

  include ApplicationHelper
  include ThingHelper
  include ThingConcern
  include JsonConcern

  before_action :set_thing


  # GET /:username/:resource/:id/metadata
  # GET /:username/:resource/:id/metadata/:key
  def show
    authorize! :read, @thing
    show_json @thing.metadata, get_key
  end


  # POST  /:username/:resource/:id/metadata
  # PUT   /:username/:resource/:id/metadata
  # POST  /:username/:resource/:id/metadata/:key
  # PATCH /:username/:resource/:id/metadata/:key
  # PUT   /:username/:resource/:id/metadata/:key
  def create
    authorize! :create, @thing

    edit_json(@thing.metadata, get_key) do |new_data|
      @thing.metadata = new_data
      @thing.paper_trail_event = 'edit metadata'
    end
  end 

  # DELETE /:username/:resource/:id/metadata
  # DELETE /:username/:resource/:id/metadata/:key
  def delete
    authorize! :delete, @thing

    delete_json(@thing.metadata, get_key) do |new_data|
      @thing.metadata = new_data
      @thing.paper_trail_event = 'delete metadata'
    end
  end

  protected
    def get_key
      if params[:metadatum_key].nil?
        return params[:key]
      end

      if params[:key].nil?
        return params[:metadatum_key]
      end

      return (params[:metadatum_key] + '/' + params[:key])
    end
end
