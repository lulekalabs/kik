module NotifierHelper

  def project_name
    @user ? @user.project_name : Project.name
  end

  def project_domain
    @user ? @user.project_domain : Project.domain
  end

  def project_host
    @user ? @user.project_host : Project.host
  end
  
end
