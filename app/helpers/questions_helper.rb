module QuestionsHelper
  def draw_when_flash
    yield if flash[:message_for_not_logged_user]
  end
  
  def draw_not_when_flash_set
    yield unless flash[:message_for_not_logged_user]
  end
end
