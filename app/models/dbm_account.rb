require 'openssl'
require 'base64'

class DbmAccount < ApplicationRecord

  belongs_to :dbm
  belongs_to :user

  def password
    pwd ||= decryption(encrypted_password)
    return pwd
  end

  def password=(val)
    self.encrypted_password = encryption(val)
  end

  protected
  def touch_configuration!
    self.configuration = {} if not configuration.is_a?(Hash)
  end

  private


  def key_base
    raise "DbmAccount must be saved before setting password" if id.nil?
    res = ENV['SECRET_KEY_BASE']
    res = id.to_s + res
    return res
  end

  def algorithm
    return 'aes-256-cbc'
  end

  def encryption(plain_string)
    begin
      plain_string += '*' # Add one extra char to handle empty string
      cipher = OpenSSL::Cipher.new(algorithm)
      cipher.encrypt()
      cipher.key = key_base.truncate(32)
      crypt = cipher.update(plain_string) + cipher.final()
      crypt_string = (Base64.encode64(crypt))
      return crypt_string
    rescue Exception => exc
      puts ("Failed to encrypt text = #{exc.message}")
    end
  end

  def decryption(crypt_string)
    begin
      cipher = OpenSSL::Cipher.new(algorithm)
      cipher.decrypt()
      cipher.key = key_base.truncate(32)
      tempkey = Base64.decode64(crypt_string)
      plain_string = cipher.update(tempkey)
      plain_string << cipher.final()
      return plain_string.chomp('*') # Remove the extra char added by encryption
    rescue Exception => exc
      puts ("Failed to decrypt text = #{exc.message}")
    end
  end

end
