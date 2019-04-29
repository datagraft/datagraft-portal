# Tracking associations is an experimental feature
PaperTrail.config.track_associations = false

module PaperTrail

  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern

    private
    def is_event_destroy?
      self.event === "destroy"
    end
  end
end
