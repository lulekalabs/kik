require File.dirname(__FILE__) + '/../test_helper'

class ReviewTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  # Replace this with your real tests.
  def test_should_create
    assert_difference "Review.count" do 
      review = Review.create valid_review_attributes
    end
  end

  def test_should_activate
    review = Review.create valid_review_attributes
    assert_equal true, review.activate!
    assert_equal :preapproved, review.current_state
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  def test_should_approve
    review = Review.create valid_review_attributes
    assert_equal true, review.activate!
    ActionMailer::Base.deliveries.clear

    assert_difference "Email.count", 2 do
      assert_equal true, review.approve!
      assert_equal :open, review.current_state
      assert_equal 2, ActionMailer::Base.deliveries.size
    end
  end
  
  def test_should_calculate_simple_grade_point_average
    assert_difference "Review.count" do 
      @review = create_review({:v => 2, :z => 3, :m => 1, :e => 1, :a => 2})
      assert_equal "1.85", @review.grade_point_average.to_s
    end
  end

  def test_should_calculate_complex_grade_point_average
    assert_difference "Review.count" do 
      @review = create_review({:v => 2, :v1 => 2, :v2 => 1, :v3 => 2, :v4 => 3, :v5 => 2, 
        :z => 1, :z1 => 2, :z2 => 2, :z3 => 1, :z4 => 1,
        :m => 2, :m1 => 1, :m2 => 2, :m3 => 2,
        :e => 2, :e1 => 1, :e2 => 2,
        :a => 1, :a1 => 1
      })
      assert_equal "1.63", @review.grade_point_average.to_s
    end
  end
  
  def test_should_count_sub_section
    review = build_review(:v1 => 2, :v2 => 3)
    assert_equal 2, review.sub_section_count(:v)
  end
  
  def test_should_average_grade_point_averages
    assert_difference "Review.count", 2 do 
      r1 = create_review({:v => 2, :z => 3, :m => 1, :e => 1, :a => 2})
      r2 = create_review({:v => 2, :v1 => 2, :v2 => 1, :v3 => 2, :v4 => 3, :v5 => 2, 
        :z => 1, :z1 => 2, :z2 => 2, :z3 => 1, :z4 => 1,
        :m => 2, :m1 => 1, :m2 => 2, :m3 => 2,
        :e => 2, :e1 => 1, :e2 => 2,
        :a => 1, :a1 => 1
      })
      assert_equal "1.85", r1.grade_point_average.to_s
      assert_equal "1.63", r2.grade_point_average.to_s
      assert_equal true, r1.activate!
      assert_equal true, r1.approve!
      assert_equal :open, r1.current_state
      assert_equal true, r2.activate!
      assert_equal true, r2.approve!
      assert_equal :open, r2.current_state
      assert_equal "1.74", people(:aaron).grade_point_average.to_s
    end
  end
  
end
