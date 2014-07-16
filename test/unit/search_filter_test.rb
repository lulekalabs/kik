require File.dirname(__FILE__) + '/../test_helper'

class SearchFilterTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  def test_should_create_kase_search_filter
    assert_difference "KaseSearchFilter.count" do
      sf = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)]})
      assert_equal 2, sf.topics.size
    end
  end
  
  def test_should_find_questions_within_radius
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        question = create_geisenfeld_question
        
        search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
          :radius => 10, :postal_code => 85119, :select_region => "radius"})
        assert_equal true, search_filter.geo_coded?
        
        questions = search_filter.with_query_scope do |query|
          query.open.since(search_filter.digested_at).all
        end
        
        assert_equal 1, questions.size 
        assert_equal question, questions.first
      end
    end
  end

  def test_should_not_find_questions_outside_radius
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        create_geisenfeld_question
        
        search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
          :radius => 5, :postal_code => 85119, :select_region => "radius"})
        assert_equal true, search_filter.geo_coded?
        
        questions = search_filter.with_query_scope do |query|
          query.open.since(search_filter.digested_at).all
        end
        
        assert_equal 0, questions.size 
      end
    end
  end
  
  def test_should_find_questions_within_province
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        question = create_geisenfeld_question
        
        search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
          :radius => nil, :postal_code => nil, :province_code => "BY", :select_region => "province"})
        assert_equal false, search_filter.geo_coded?
        
        questions = search_filter.with_query_scope do |query|
          query.open.since(search_filter.digested_at).all
        end
        
        assert_equal 1, questions.size 
        assert_equal question, questions.first
      end
    end
  end

  def test_should_not_find_questions_outside_province
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        question = create_geisenfeld_question
        
        search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
          :radius => nil, :postal_code => nil, :province_code => "BW", :select_region => "province"})
        assert_equal false, search_filter.geo_coded?
        
        questions = search_filter.with_query_scope do |query|
          query.open.since(search_filter.digested_at).all
        end
        
        assert_equal 0, questions.size 
      end
    end
  end

  def test_should_deliver_digest
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        question = create_geisenfeld_question
        
        search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
          :radius => nil, :postal_code => nil, :province_code => "BY", :select_region => "province"})
        assert_equal false, search_filter.geo_coded?
        
        questions = search_filter.with_query_scope do |query|
          query.open.since(search_filter.digested_at).all
        end
        
        assert_equal 1, questions.size 
        ActionMailer::Base.deliveries.clear
        SearchFilterMailer.deliver_digest(search_filter, questions)
        assert_equal 1, ActionMailer::Base.deliveries.size
        assert_equal true, ActionMailer::Base.deliveries.first.body.include?(question.summary)
      end
    end
  end

  def test_should_enqueue_digest
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        search_filter = nil
        question = nil
        pretend_now_is Time.now.utc - 2.days do
          search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
            :radius => nil, :postal_code => nil, :province_code => "BY", :select_region => "province",
              :digest => "d"})
        end
        assert_equal false, search_filter.geo_coded?

        pretend_now_is Time.now.utc - 18.hours do
          question = create_geisenfeld_question
        end

        ActionMailer::Base.deliveries.clear

        KaseSearchFilterJob.new.perform
        search_filter.reload

        assert search_filter.digested_at, "should be set"
        assert_equal 1, ActionMailer::Base.deliveries.size
        assert_equal true, ActionMailer::Base.deliveries.first.body.include?(question.summary)
      end
    end
  end
  
  def test_should_enqueue_digest
    assert_difference "Question.count" do
      assert_difference "KaseSearchFilter.count" do
        assert_difference "Delayed::Job.count" do
          search_filter = create_kase_search_filter({:topics => [topics(:arbeitsrecht), topics(:agrarrecht)],
            :radius => nil, :postal_code => nil, :province_code => "BY", :select_region => "province", :digest => "i"})
          assert_equal false, search_filter.geo_coded?
          question = create_geisenfeld_question
        end
      end
    end
  end
  
  protected
  
  def create_geisenfeld_question
    question = create_question(:postal_code => 85290, :topics => [topics(:arbeitsrecht)])
    assert_equal true, question.geo_coded?
    assert_equal true, question.activate!
    assert_equal true, question.approve!
    assert_equal :open, question.current_state
    question
  end
  
  def valid_kase_search_filter_attributes(options={})
    {:postal_code => 85119, :person => people(:quentin), :radius => 20, :province_code => nil,
      :digest => "n", :topics => [topics(:arbeitsrecht), topics(:agrarrecht)], :select_region => "radius"}.merge(options)
  end
  
  def create_kase_search_filter(options={})
    KaseSearchFilter.create(valid_kase_search_filter_attributes(options))
  end

  def build_kase_search_filter(options={})
    KaseSearchFilter.new(valid_kase_search_filter_attributes(options))
  end
  
end
