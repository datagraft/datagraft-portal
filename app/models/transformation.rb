#require 'net/http/post/multipart'
require 'rest-client'

class Transformation < Thing
  extend FriendlyId
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]
  attachment :file

  def transform (data_file, transform_type)
    temp_data = data_file.download
    temp_pipeline_io = data_file.backend.upload(StringIO.new(self.code))
    temp_pipeline = temp_pipeline_io.download
    request = RestClient::Request.new(
      :method => :post,
      :url => Rails.configuration.graftwerk['publicPath'] + '/evaluate/' + transform_type,
      :payload => {
        :multipart => true,
        :data => File.new(temp_data.path),
        :pipeline => File.new(temp_pipeline.path),
        :command => 'my-' + transform_type
        },
      :headers => {
        "Accept" => transform_type == 'pipe' ? 'application/csv' : 'application/n-triples'
        })

    begin
      response = request.execute
      throw "Error executing transformation (empty result)." if response.body.empty?
      new_file = data_file.backend.upload(StringIO.new(response.body))
      return new_file
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
      throw "Failed to execute transformation."
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      throw "Failed to execute transformation. Unknown error."
    end

  end


  def transform_graft
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def code
    configuration["code"] unless configuration.blank?
  end

  def code=(val)
    touch_configuration!
    configuration["code"] = val
  end

end
