#require 'net/http/post/multipart'
require 'rest-client'

class Transformation < Thing
  extend FriendlyId
  # friendly_id :name, :use => [:history, :scoped], :scope => :user
  friendly_id :name, :use => [:history, :scoped], :scope => [:user, :type]
  # friendly_id :name, :use => :history

  #  def new_graftwerk_connection
  #    Faraday.new(:url => Rails.configuration.graftwerk['publicPath']) do |faraday|
  #      faraday.request :multipart
  #
  #      faraday.response :logger                  # log requests to STDOUT
  ##      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  #      faraday.adapter :net_http
  #    end
  #  end

  def transform (data_file, transform_type)

    #    conn = new_graftwerk_connection
    #    puts self.code
    #    temp_data = data_file.download
    #    temp_pipeline_io = data_file.backend.upload(StringIO.new(self.code))
    #    temp_pipeline = temp_pipeline_io.download
    #    byebug
    #    pipe_result = conn.post do |req|
    #      # 'pipe' or 'graft'
    #      req.url '/evaluate/' + transform_type
    #      req.headers['accept'] = transform_type == 'pipe' ? 'text/csv' : 'application/n-triples'
    #      req.headers['content-type'] = 'multipart/form-data'
    #      req.body = {
    #        data: Faraday::UploadIO.new(temp_data.path, 'text/plain', 'input.csv', "Content-Disposition" => "file"),
    #        pipeline: Faraday::UploadIO.new(temp_pipeline.path, 'text/plain', 'transform.clj', "Content-Disposition" => "file"),
    #        command: transform_type
    #        }.to_json
    #      puts req
    #      puts req.headers
    #      puts req.body
    #    end
    #    puts pipe_result


    #    temp_data = data_file.download
    #    temp_pipeline_io = data_file.backend.upload(StringIO.new(self.code))
    #    temp_pipeline = temp_pipeline_io.download
    #    
    #    url = URI.parse(Rails.configuration.graftwerk['publicPath'] + '/evaluate/' + transform_type) 
    #    req = Net::HTTP::Post::Multipart.new url.path, "data" => UploadIO.new(File.new(temp_data.path), 'text/plain', 'input.csv', "Content-Disposition" => "file"), "pipeline" => UploadIO.new(File.new(temp_pipeline.path), 'text/plain', 'transform.clj', "Content-Disposition" => "file"), "command" => transform_type
    #
    #    byebug
    #    
    #    http = Net::HTTP.new(url.host, url.port)
    #    http.set_debug_output($stdout)
    #    response = http.request(req)

    #    res = Net::HTTP.start(url.host, url.port) do |http|
    #      byebug
    #      
    #    end

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
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      throw "Failed to execute transformation. Unknown error."
    end

  end


  #  def transform_pipe(data_file)
  #    conn = new_graftwerk_connection
  #    pipe_result = conn.post do |req|
  #      req.url '/evaluate/pipe'
  #      req.params['command'] = 'pipe'
  #      req.body = {
  #    end 
  #  end

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
