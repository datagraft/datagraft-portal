module UpwizardHelper
  def upwizard_delete_path(upwizard_input)
    "/#{upwizard_input.user.username}/upwizards/#{upwizard_input.id}"
  end
  def upwizard_index_path(user_input)
    "/#{current_user.username}/upwizards"
  end
  def upwizard_new_path(type)
    "/#{current_user.username}/upwizards/new/#{type}"
  end
end
