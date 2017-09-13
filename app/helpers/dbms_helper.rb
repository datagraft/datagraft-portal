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
