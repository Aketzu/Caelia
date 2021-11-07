# frozen_string_literal: true

require 'test_helper'

class SourcefilesControllerTest < ActionController::TestCase
  test 'should get picker' do
    get :picker
    assert_response :success
  end
end
