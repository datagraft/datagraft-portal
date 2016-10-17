# Tracking associations is an experimental feature
PaperTrail.config.track_associations = false

module PaperTrail
  class Version < ActiveRecord::Base
    # Updates metric for versions; we do it only on creation of a version unless the event that triggered the version creation is "destroy" (yes, we also store versions of destroyed assets), which means that we do not need to increment versions
    after_create_commit :increment_versions_metric, unless: :is_event_destroy?

    # increments the value of the version metric for the asset type of the asset we create a version for
    def increment_versions_metric
      begin
        byebug
        num_versions = Prometheus::Client.registry.get(:num_versions)
        curr_num_versions_metric_val = num_versions.get({asset_type: self.item.type})
        num_versions.set({asset_type: self.item.type}, curr_num_versions_metric_val + 1)
      rescue Exception => e  
        puts 'Error incrementing num_versions metric'
        puts '!'
        puts e.message  
        puts e.backtrace.inspect
      end
    end

    private
    def is_event_destroy?
      self.event === "destroy"
    end
  end
end