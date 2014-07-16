class UserObserver < ActiveRecord::Observer

=begin
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
  end

  def after_save(user)
    if user.recently_activated?
      UserMailer.deliver_activation(user)
    elsif :inactive == user.current_state
      UserMailer.deliver_pre_launch_activation(user)
    end
  end
=end

end
