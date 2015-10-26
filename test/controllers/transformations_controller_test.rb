require 'test_helper'

class TransformationsControllerTest < ActionController::TestCase
  setup do
    @transformation = things(:water)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transformations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transformation" do
    assert_difference('Transformation.count') do
      post :create, transformation: { 
        name: 'A new public transformation',
        public: true
      }
    end

    assert_redirected_to transformation_path(assigns(:transformation))
  end

  test "should show transformation" do
    get :show, id: @transformation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transformation
    assert_response :success
  end

  test "should update transformation" do
    patch :update, id: @transformation, transformation: {  }
    assert_redirected_to transformation_path(assigns(:transformation))
  end

  test "should destroy transformation" do
    assert_difference('Transformation.count', -1) do
      delete :destroy, id: @transformation
    end

    assert_redirected_to transformations_path
  end
end
