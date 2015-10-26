require 'test_helper'

class DataDistributionsControllerTest < ActionController::TestCase
  setup do
    @data_distribution = things(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_distributions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_distribution" do
    assert_difference('DataDistribution.count') do
      post :create, data_distribution: {
        name: 'A new public distribution',
        public: true
      }
    end

    assert_redirected_to data_distribution_path(assigns(:data_distribution))
  end

  test "should show data_distribution" do
    get :show, id: @data_distribution
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @data_distribution
    assert_response :success
  end

  test "should update data_distribution" do
    patch :update, id: @data_distribution, data_distribution: {
      public: true
    }
    assert_redirected_to data_distribution_path(assigns(:data_distribution))
  end

  test "should destroy data_distribution" do
    assert_difference('DataDistribution.count', -1) do
      delete :destroy, id: @data_distribution
    end

    assert_redirected_to data_distributions_path
  end
end
