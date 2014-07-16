require File.dirname(__FILE__) + '/../test_helper'

class ExpertiseTest < ActiveSupport::TestCase
  fixtures :all

  def test_simple_new
    assert @enrollment = Entrollment.new
  end
    
end
