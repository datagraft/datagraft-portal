class ApiKey < ApplicationRecord
  belongs_to :user

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

  private
    def get_key_without_secret
      r = /^(.+):/.match(key)
      r ? r[1] : nil
    end
end
