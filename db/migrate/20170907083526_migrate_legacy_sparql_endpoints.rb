class MigrateLegacySparqlEndpoints < ActiveRecord::Migration[5.0]
  
  def up
    Thing.reset_column_information
    all_users = User.all
    all_users.each do |user|
      say "Checking user #{user.id} #{user.name}"

      make_ontotext_leg_and_connect(user)

      all_users_dbms = user.dbms.all
      all_users_dbms.each do |dbm|
        connect_all_api_keys_to_user(dbm)
      end
    end

  end

  def down
    # Nothing to do in down method
  end

  def make_ontotext_leg_and_connect(user)
    db_leg_list = user.dbms.where(type: "DbmOntotextLeg")
    ep_unconn_list = user.sparql_endpoints.where(rdf_repo: nil)
    say "  Found #{db_leg_list.count} DbmOntotextLeg and #{ep_unconn_list.count} non connected SparqlEndpoints"

    unless ep_unconn_list.count == 0
      say "    Some SparqlEndpoint has to be migrated"

      dbm = db_leg_list.first
      if dbm == nil
        say "      A DbmOntotextLeg has to be created"
        dbm = DbmOntotextLeg.new
        dbm.name = "OntotextLegacy"
        dbm.user = user
        dbm.save
      end

      say "    Using Dbm #{dbm.name} type #{dbm.type} id #{dbm.id}"
      say "    Connecting the unconnected SparqlEndpoints"

      ep_unconn_list.each do |ep|
        rr = RdfRepo.new
        rr.name = "RR_leg:#{ep.slug}"
        rr.uri = ep.uri
        rr.dbm = dbm
        rr.is_public = ep.public
        rr.save!
        ep.rdf_repo = rr
        ep.save!
        say "      For SparqlEndpoint #{ep.id} #{ep.slug} created RdfRepo #{ep.rdf_repo.id} #{ep.rdf_repo.name} connected to Dbm dbm.id #{ep.rdf_repo.dbm.id}"
      end

    else
      say "    Nothing to do"
    end

    # Counting up usage...
    db_list = user.dbms.all
    db_use = {}
    failing_dbm = 0
    failing_rr = 0
    db_list.each do |dbm|
      db_use[dbm.id] = 0
    end

    ep_list = user.sparql_endpoints.all
    ep_list.each do |ep|
      unless ep.rdf_repo == nil
        unless ep.rdf_repo.dbm == nil
          dbm_id = ep.rdf_repo.dbm_id
          db_use[dbm_id] = db_use[dbm_id] + 1
        else
          failing_dbm = failing_dbm + 1
        end
      else
        failing_rr = failing_rr + 1
      end
    end

    say "  Status summary"
    db_list.each do |dbm|
      say "    Found #{db_use[dbm.id]} SparqlEndpoints connected to Dbm #{dbm.name} type #{dbm.type} id #{dbm.id}"
    end
    say "    ERROR **** Found #{failing_rr} SparqlEndpoints connected to missing RdfRepos" if failing_rr > 0
    say "    ERROR **** Found #{failing_dbm} SparqlEndpoints connected to missing Dbms" if failing_dbm > 0
    say " "

  end


  def connect_all_api_keys_to_user(dbm)
    say "  Checking ApiKeys for Dbm #{dbm.id} #{dbm.type} #{dbm.name}"

    key_list = dbm.api_keys.all
    key_list.each do |ak|
      if ak.user == nil
        ak.user = dbm.user
        ak.save
        say "    Connecting ApiKey.id #{ak.id} to user.id #{ak.user.id}"
      end
    end
  end

end
