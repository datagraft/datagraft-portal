class ConfigurationController < ApplicationController

  include ApplicationHelper
  include ThingHelper
  include ThingConcern
  include JsonConcern

  before_action :set_thing

  # GET /:username/:resource/:id/configuration
  # GET /:username/:resource/:id/configuration/:key
  def show
    authorize! :read, @thing
    show_json @thing.configuration, get_key
  end


  # POST  /:username/:resource/:id/configuration
  # PUT   /:username/:resource/:id/configuration
  # POST  /:username/:resource/:id/configuration/:key
  # PATCH /:username/:resource/:id/configuration/:key
  # PUT   /:username/:resource/:id/configuration/:key
  def create
    authorize! :create, @thing

    edit_json(@thing.configuration, get_key) do |new_data|
      @thing.configuration = new_data
      @thing.paper_trail_event = 'edit configuration'
    end
  end 

  # DELETE /:username/:resource/:id/configuration
  # DELETE /:username/:resource/:id/configuration/:key
  def delete
    authorize! :delete, @thing

    delete_json(@thing.configuration, get_key) do |new_data|
      @thing.configuration = new_data
      @thing.paper_trail_event = 'delete configuration'
    end
  end

  protected
    def get_key
      if params[:configuration_key].nil?
        return params[:key]
      end

      if params[:key].nil?
        return params[:configuration_key]
      end

      return (params[:configuration_key] + '/' + params[:key])
    end
end
