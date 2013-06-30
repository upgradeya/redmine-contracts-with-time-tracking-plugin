class ContractsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize, :only => [:index, :show, :new, :create, :edit, :update, :destroy, 
                                                     :add_time_entries, :assoc_time_entries_with_contract]
  
  def index
    @project = Project.find(params[:project_id])
    @contracts = Contract.order("start_date ASC").where(:project_id => @project.id)
    @total_purchased_dollars = @project.total_amount_purchased
    @total_purchased_hours   = @project.total_hours_purchased
    @total_remaining_dollars = @project.total_amount_remaining
    @total_remaining_hours   = @project.total_hours_remaining
  end

  def all
    @user = User.current
    @projects = @user.projects.select { |project| @user.roles_for_project(project).
                                                        first.permissions.
                                                        include?(:view_all_contracts_for_project) }
    @contracts = @projects.collect { |project| project.contracts.order("start_date ASC") }
    @contracts.flatten!
    @total_purchased_dollars = @contracts.sum { |contract| contract.purchase_amount }
    @total_purchased_hours   = @contracts.sum { |contract| contract.hours_purchased }
    @total_remaining_dollars = @contracts.sum { |contract| contract.amount_remaining }
    @total_remaining_hours   = @contracts.sum { |contract| contract.hours_remaining }
    
    render "index"
  end

  def new
    @contract = Contract.new
    @project = Project.find(params[:project_id])
    @project.contracts.empty? ? num = "001" : num = ("%03d" % (@project.contracts.last.id + 1))
    @new_title = @project.identifier + "_Dev_" + num
    load_contractors_and_rates
  end

  def create
    @contract = Contract.new(params[:contract])
    rates = params[:rates]
    # Ensure only positive-value rates are entered
    if !rates.nil?
      rates.each_pair do |user_id, rate|
        if rate.to_f < 0
          flash[:error] = l(:text_invalid_rate)
          redirect_to :action => "new", :id => @contract.id
          return
        end
      end
    end
    @contract.rates = rates
    if @contract.save
      flash[:notice] = l(:text_contract_saved)
      redirect_to :action => "show", :id => @contract.id
    else
      flash[:error] = "* " + @contract.errors.full_messages.join("</br>* ")
      redirect_to :action => "new", :id => @contract.id
    end
  end

  def show
    @contract = Contract.find(params[:id])
    @time_entries = @contract.time_entries.order("spent_on DESC")
    @members = []
    @time_entries.each { |entry| @members.append(entry.user) unless @members.include?(entry.user) }
    @expenses_tab = (params[:expenses] == 'true')
    if @expenses_tab
      @expenses = @contract.expenses
    end
  end

  def edit
    @contract = Contract.find(params[:id])
    @projects = Project.all
    load_contractors_and_rates
  end

  def update
    @contract = Contract.find(params[:id])
    if @contract.update_attributes(params[:contract])
      @rate_error = false
      rates = params[:rates]
      @contract.rates = params[:rates]
      rates.each_pair do |user_id, rate|
        if rate.to_f <= 0
          rate_error = true
        end
      end
      if @rate_error
        flash[:error] = l(:text_invalid_rate)
        redirect_to :action => "edit", :id => @contract.id
      else
        @contract.save
        flash[:notice] = l(:text_contract_updated)
        redirect_to :action => "show", :id => @contract.id 
      end
    else
      flash[:error] = "* " + @contract.errors.full_messages.join("</br>* ")
      redirect_to :action => "edit", :id => @contract.id
    end
  end

  def destroy
    @contract = Contract.find(params[:id])
    if @contract.destroy
      flash[:notice] = l(:text_contract_deleted)
      if !params[:project_id].nil?
        redirect_to :action => "index", :project_id => params[:project_id]
      else
        redirect_to :action => "all"
      end
    else
      redirect_to(:back)
    end
  end

  def add_time_entries
    @contract = Contract.find(params[:id])
    @project = @contract.project
    @time_entries = @contract.project.time_entries_for_all_descendant_projects.sort_by! { |entry| entry.spent_on }
  end

  def assoc_time_entries_with_contract
    @contract = Contract.find(params[:id])
    @project = @contract.project
    time_entries = params[:time_entries]
    if time_entries != nil
      time_entries.each do |time_entry| 
        updated_time_entry = TimeEntry.find(time_entry.first)
        updated_time_entry.contract = @contract
        updated_time_entry.save
      end
    end
    unless @contract.hours_remaining >= 0
      flash[:error] = l(:text_hours_over_contract, :hours_over => l_hours(-1 * @contract.hours_remaining))
    end
    redirect_to url_for({ :controller => 'contracts', :action => 'show', :project_id => @project.identifier, :id => @contract.id })
  end

  def archive
    @contract = Contract.find(params[:id])
    @lock = (params[:lock] == 'true')
    if @lock
      @contract.update_attribute(:is_archived, @lock)
      flash[:notice] = l(:text_contract_locked)
    else
      @contract.is_archived = false
      @contract.hours_worked = nil
      @contract.billable_amount_total = nil
      @contract.save!
      flash[:notice] = l(:text_contract_unlocked)
    end
    redirect_to url_for({ :controller => 'contracts', :action => 'show', :project_id => @contract.project.identifier, :id => @contract.id })
  end

  private

  def load_contractors_and_rates
    @contractors = Contract.users_for_project_and_sub_projects(@project)
    @contractor_rates = {}
    @contractors.each do |contractor|
      if @contract.new_record?
        rate = @project.rate_for_user(contractor)
      else
        rate = @contract.user_contract_rate_or_default(contractor)
      end
      @contractor_rates[contractor.id] = rate
    end
  end

  def find_project
    #@project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id]) 
  end

end
