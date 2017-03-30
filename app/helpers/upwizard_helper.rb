module UpwizardHelper
  def upwizard_delete_path(upwizard_input)
    "/upwizards/#{upwizard_input.id}"
  end
  def upwizard_index_path()
    "/#{current_user.username}/upwizards"
  end
  def upwizard_new_path(type)
    "/#{current_user.username}/upwizards/new/#{type}"
  end

  # Extract file extension from filename
  def file_ext(filename)
    unless filename.blank?
      tmp_name = filename
      ext_with_dot = File.extname(tmp_name)
      ext_no_dot = ext_with_dot.slice(1, ext_with_dot.length)
      return ext_no_dot
    else
      return nil
    end
  end


end
