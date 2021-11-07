# frozen_string_literal: true

require 'test_helper'

class VodsControllerTest < ActionController::TestCase
  setup do
    @vod = vods(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:vods)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create vod' do
    assert_difference('Vod.count') do
      post :create, vod: {}
    end

    assert_redirected_to vod_path(assigns(:vod))
  end

  test 'should show vod' do
    get :show, id: @vod
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @vod
    assert_response :success
  end

  test 'should update vod' do
    patch :update, id: @vod, vod: {}
    assert_redirected_to vod_path(assigns(:vod))
  end

  test 'should destroy vod' do
    assert_difference('Vod.count', -1) do
      delete :destroy, id: @vod
    end

    assert_redirected_to vods_path
  end
end
