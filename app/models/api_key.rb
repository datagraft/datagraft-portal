class ApiKey < ApplicationRecord
  belongs_to :user
  belongs_to :dbm

  def add_in_dbm
    dbm.key_added(self)
  end

  def update_in_dbm
    dbm.key_updated(self)
  end

  def delete_in_dbm
    dbm.key_deleted(self)
  end

  def new_ontotext_api_key(user)
    #Devise.friendly_token(32)
    key = user.new_ontotext_api_key

    if !enabled
      user.disable_ontotext_api_key(key['api_key'])
    end

    # We store the secret because we don't give a duck
    key['api_key']+':'+key['secret']

  end



  def delete_from_ontotext(user)
    tmp_key = get_key_without_secret
    user.delete_ontotext_api_key(tmp_key) unless tmp_key.nil?
  end

  def update_in_ontotext(user)
    tmp_key = get_key_without_secret
    return if tmp_key.nil?

    if enabled
      user.enable_ontotext_api_key(tmp_key)
    else
      user.disable_ontotext_api_key(tmp_key)
    end
  end

  def self.first_or_create(user)
    key = user.api_keys.where(enabled: true).first

    # Create a key if one doesn't exist yet
=begin
    if key.nil?
      key = ApiKey.new
      key.enabled = true
      key.name = 'Automatically generated Ontotext API Key'
      key.user = user
      key.key = key.new_ontotext_api_key(user)
      key.save

      # TODO : Check if this definitely removes the bad credentials bug…
      sleep 5
    end
=end
    key
  end

  def key_pub
    r = /^(.+):/.match(key)
    kp = r ? r[1] : ''
    return kp
  end

  def key_pub=(kp)
    ks = key_secret
    self.key = kp +':'+ ks
  end

  def key_secret
    r = /:(.+)/.match(key)
    ks = r ? r[1] : ''
    return ks
  end

  def key_secret=(ks)
    kp = key_pub
    self.key = kp +':'+ ks
  end


  private
    def get_key_without_secret
      r = /^(.+):/.match(key)
      r ? r[1] : nil
    end
end
