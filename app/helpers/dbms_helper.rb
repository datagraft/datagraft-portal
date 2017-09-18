module DbmsHelper

  # Find how many transformations the user has
  def dbms_descriptive_name(dbm)

    if dbm == nil
      res = "No database"
    else
      res = "DBM(#{dbm.name})"
    end
    return res
  end

  def dbms_repo_info(repo)
    if repo == nil
      res = dbms_descriptive_name(nil)
    else
      dbm = repo.dbm
      res = "#{dbms_descriptive_name(dbm)}:#{repo.name}"
    end
    return res
  end
end

def dbm_things_path(dbm)
  dbm_generic_path(dbm, '/things')
end


def dbm_generic_path(dbm, method)
  "/dbms/#{dbm.id}/#{method}"
end
