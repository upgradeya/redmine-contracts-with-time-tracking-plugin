require File.expand_path('../../test_helper', __FILE__)

class ContractsControllerTest < ActionController::TestCase
  fixtures :contracts, :projects

  def setup
    @contract = contracts(:contract_one)
    @project = projects(:projects_001)
    @contract.project_id = @project.id
  end

  test "should get index" do 
    get :index, :project_id => @project.id
    assert_response :success
    assert_not_nil assigns(:contracts)
    assert_not_nil assigns(:total_purchased_dollars)
    assert_not_nil assigns(:total_purchased_hours)
    assert_not_nil assigns(:total_remaining_dollars)
    assert_not_nil assigns(:total_remaining_hours)
  end

  test "should get new" do
    @request.session[:user_id] = 1
    get :new, :project_id => @project.id 
    assert_response :success
    assert_not_nil assigns(:contract)
  end

  test "should create new contract" do
    assert_difference('Contract.count') do
      post :create, :project_id => @project.identifier,
                   :contract => { :title => "New Title",
                                  :description => @contract.description,
                                  :agreement_date => @contract.agreement_date,
                                  :start_date => @contract.start_date,
                                  :end_date => @contract.end_date,
                                  :purchase_amount => @contract.purchase_amount,
                                  :hourly_rate => @contract.hourly_rate,
                                  :project_id => @project.id
                                }
    end
    assert_not_nil assigns(:contract)
    assert_redirected_to :action => "show", :project_id => @project.identifier, :id => assigns(:contract)
  end

  test "should get show" do
    @request.session[:user_id] = 1
    get :show, :project_id => @project.id, :id => @contract.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:time_entries)
  end

  test "should get edit" do
    @request.session[:user_id] = 1
    get :edit, :project_id => @project.id, :id => @contract.id
    assert_response :success
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:projects)
  end

  test "should update contract" do
    @contract.save
    assert_no_difference('Contract.count') do
      put :update, :project_id => @project.id, :id => @contract.id, 
          :contract => {  :title => @contract.title,
                          :description => @contract.description,
                          :agreement_date => @contract.agreement_date,
                          :start_date => @contract.start_date,
                          :end_date => @contract.end_date,
                          :purchase_amount => @contract.purchase_amount,
                          :hourly_rate => @contract.hourly_rate,
                          :project_id => @contract.project_id
                        }
    end
    assert_redirected_to :action => "show", :project_id => @project.id, :id => assigns(:contract).id 
  end

  test "should get all contracts" do
    get :all
    assert_response :success
    assert_not_nil assigns(:contracts)
    assert_not_nil assigns(:total_purchased_dollars)
    assert_not_nil assigns(:total_purchased_hours)
    assert_not_nil assigns(:total_remaining_dollars)
    assert_not_nil assigns(:total_remaining_hours)    
  end

  test "should destroy contract" do
    assert_difference('Contract.count', -1) do
      delete :destroy, :project_id => @project.id, :id => @contract.id
    end
  end


end
