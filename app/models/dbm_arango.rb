require 'rest-client'

class DbmArango < Dbm

  # Non-persistent attribute for storing inputs from new form
  attr_accessor :dbm_account_username
  attr_accessor :dbm_account_password

  ######
  public
  ######

  @@supported_repository_types = %w(ARANGO)
  def get_supported_repository_types
    return @@supported_repository_types
  end

  def uri
    configuration["uri"] if configuration
  end

  def uri=(val)
    touch_configuration!
    configuration["uri"] = val
  end

  def find_things
    adb = []
    self.things.each do |thing|
      adb << thing
    end
    return adb
  end

  # Create a collection in a database
  def create_collection(db_name, collection_name)
    puts "***** Enter DbmArango.create_collection(#{name})"
    puts "***** Exit DbmArango.create_collection()"
  end

  # Fetch list of collections from a database
  def get_collections(db_name)
    puts "***** Enter DbmArango.get_collections(#{name})"
    collections = []
    puts "***** Exit DbmArango.get_collections()"
    return collections
  end

  def get_collection_status(db_name, collection_name)
    puts "***** Enter DbmArango.get_collection_status(#{name})"
    status = {}
    puts "***** Exit DbmArango.get_collection_status()"
    return status
  end

  # Delete collection
  def delete_collection(db_name, collection_name)
    puts "***** Enter DbmArango.delete_collection(#{name})"
    puts "***** Exit DbmArango.delete_collection()"
  end


  ##private

end
