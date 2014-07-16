module AuthenticatedTestHelper
  # Sets the current admin_user in the session from the admin_user fixtures.
  def login_as_admin(login_user)
    @request.session[:admin_user_id] = login_user ? admin_users(login_user).id : nil
  end

  # Sets the current admin_user in the session from the admin_user fixtures.
  def login_as(login_user)
    @request.session[:user_id] = login_user ? users(login_user).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
