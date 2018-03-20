module JsonConcern
  extend ActiveSupport::Concern

  def show_json(data, key = nil)
    if not key.nil?
      data = Rodash.get(data, key)
      not_found if not data
    end
    
    if data.kind_of? String
      render :plain => data
    else
      render :json => data
    end
  end

  def edit_json(full_data, key = nil)

    # Use raw_post because it doesn't contain magic variables
    data = request.raw_post

    begin
      data = JSON.parse(data)    
    rescue JSON::ParserError => e
      # Automatically convert few json types
      if data == 'true'
        data = true
      elsif data == 'false'
        data = false
      elsif data =~ /\./
        data = Float(data) rescue data
      else
        data = Integer(data) rescue data
      end
    end

    if key
      Rodash.set(full_data, key, data)
      yield full_data
    else
      yield data
    end

    if @thing.save
      head :created
    else
      render json: @thing.errors, status: :unprocessable_entity
    end
  end

  def delete_json(full_data, key)
    if key
      Rodash.unset(full_data, key)
      yield full_data
    else
      yield nil
    end

    if @thing.save
      head :ok
    else
      render json: @thing.errors, status: :unprocessable_entity
    end
  end

end