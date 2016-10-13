module UpwizardHelper
  def upwizard_delete_path(upwizard_input)
    "/#{upwizard_input.user.username}/upwizard/#{upwizard_input.id}"
  end
  def upwizard_index_path(user_input)
    "/#{user_input.username}/upwizard"
  end
end
