class MigrateRemoveLooseRdfRepos < ActiveRecord::Migration[5.0]
  def up
    all_users = User.all
    all_users.each do |user|
      say "Checking user #{user.id} #{user.name}"

      all_users_dbms = user.dbms.all
      all_users_dbms.each do |dbm|
        remove_loose_rdf_repos(dbm)
      end
    end

  end

  def down
    # Nothing to do in down method
  end

  def remove_loose_rdf_repos(dbm)
    say "  Checking RdfRepos for Dbm #{dbm.id} #{dbm.type} #{dbm.name}"

    deleted = false
    rr_list = dbm.rdf_repos.all
    rr_list.each do |rr|
      if rr.things.count == 0
        say "    Deleting RdfRepo #{rr.id} #{rr.name} to dbm.id #{dbm.id}"
        rr.delete
        deleted = true
      end
    end
    say "    Nothing to fix" unless deleted
  end

end
