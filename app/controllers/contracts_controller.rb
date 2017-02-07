class ContractsController < ApplicationController
  before_filter :find_project, :authorize, :only => [:index, :show, :new, :create, :edit, :update, :destroy, 
                                                     :add_time_entries, :assoc_time_entries_with_contract]
  
  def index
    @project = Project.find(params[:project_id])

    fixed_contracts = Contract.order("start_date ASC").where(:project_id => @project.id, :is_fixed_price => '1')
    hourly_contracts = Contract.order("start_date ASC").where(:project_id => @project.id, :is_fixed_price => '0')

    # Show the tabs only if there are hourly and fixed contracts within the same project.
    if fixed_contracts.size > 0 && hourly_contracts.size > 0
      @show_tabs = true
    end

    # Show fixed contracts if the fixed tab is selected or if there aren't any hourly contracts.
    @show_fixed_contracts = (fixed_contracts.size > 0 && hourly_contracts.size == 0) || params[:fixed_tab_active] == 'true'

    # Set @contracts to the fixed our hourly array of contracts to be displayed.
    if @show_fixed_contracts
      @contracts = fixed_contracts
    else
      @contracts = hourly_contracts
    end
    
    # Calculate metrics for display.
    @total_purchased_dollars = @project.total_amount_purchased
    @total_purchased_fixed = fixed_contracts.map(&:purchase_amount).inject(0, &:+)
    @total_purchased_hourly = hourly_contracts.map(&:purchase_amount).inject(0, &:+)
    @total_purchased_hourly_hours = hourly_contracts.map(&:hours_purchased).inject(0, &:+)
    @total_amount_remaining_hourly = hourly_contracts.map(&:amount_remaining).inject(0, &:+)
    @total_remaining_hours = hourly_contracts.map(&:hours_remaining).inject(0, &:+)

    set_contract_visibility

  end

  def all
    user = User.current
    projects = user.projects.select { |project| user.allowed_to?(:view_all_contracts_for_project, project) }

    fixed_contracts = projects.collect { |project| project.contracts.order("start_date ASC").where(:is_fixed_price => '1') }
    fixed_contracts.flatten!
    hourly_contracts = projects.collect { |project| project.contracts.order("start_date ASC").where(:is_fixed_price => '0') }
    hourly_contracts.flatten!
    all_contracts = projects.collect { |project| project.contracts.order("start_date ASC") }
    all_contracts.flatten!

    # Show the tabs only if there are hourly and fixed contracts within the same project.
    if fixed_contracts.size > 0 && hourly_contracts.size > 0
      @show_tabs = true
    end

    # Show fixed contracts if the fixed tab is selected or if there aren't any hourly contracts.
    @show_fixed_contracts = (fixed_contracts.size > 0 && hourly_contracts.size == 0) || params[:fixed_tab_active] == 'true'

    if @show_fixed_contracts
      @contracts = fixed_contracts
    else
      @contracts = hourly_contracts
    end

    @total_purchased_dollars = all_contracts.sum { |contract| contract.purchase_amount }
    @total_purchased_fixed = fixed_contracts.sum { |contract| contract.purchase_amount }
    @total_purchased_hourly = hourly_contracts.sum { |contract| contract.purchase_amount }
    @total_purchased_hourly_hours = hourly_contracts.sum { |contract| contract.hours_purchased }
    @total_amount_remaining_hourly = hourly_contracts.sum { |contract| contract.amount_remaining }
    @total_remaining_hours = hourly_contracts.sum { |contract| contract.hours_remaining }

    set_contract_visibility
    
    render "index"
  end

  def new
    @contract = Contract.new
    @project = Project.find(params[:project_id])
    @new_id = @project.contracts.empty? ? 1 : @project.contracts.last.project_contract_id + 1
    @previous_id = @project.contracts.empty? ? nil : @project.contracts.last.project_contract_id
    load_contractors_and_rates
  end

  def create
    @contract = Contract.new(contract_params)
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
      @previous_id = @project.contracts.empty? ? nil : @project.contracts.last.project_contract_id
      @new_id = @contract.project_contract_id
      load_contractors_and_rates
      render :new
    end
  end

  def show
    @contract = Contract.find(params[:id])
    @time_entries = @contract.time_entries.order("spent_on DESC")
    @members = []
    @time_entries.each { |entry| @members.append(entry.user) unless @members.include?(entry.user) }
    @expenses_tab = (params[:contracts_expenses] == 'true')
    @summary_tab = (params[:contract_summary] == 'true')
    if @expenses_tab
      @expenses = @contract.contracts_expenses
    end
    if @summary_tab
      @issues = []
      @time_entries.each { |entry| @issues.append(entry.issue) unless @issues.include?(entry.issue) }
      @issues.sort! { |a,b| @contract.amount_spent_on_issue(b) <=> @contract.amount_spent_on_issue(a)}
    end

  end

  def edit
    @contract = Contract.find(params[:id])
    @projects = Project.all
    @new_id = @contract.project_contract_id
    load_contractors_and_rates
  end

  def update
    @contract = Contract.find(params[:id])
    if @contract.update_attributes(contract_params)
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
    redirect_to "/projects/#{@contract.project.id}/contracts/#{@contract.id}" 
  end

  def lock
    @contract = Contract.find(params[:id])
    @lock = (params[:lock] == 'true')
    if @lock
      @contract.update_attribute(:is_locked, @lock)
      flash[:notice] = l(:text_contract_locked)
    else
      @contract.is_locked = false
      @contract.hours_worked = nil
      @contract.billable_amount_total = nil
      @contract.save!
      flash[:notice] = l(:text_contract_unlocked)
    end

    if params[:view] == 'index'
      redirect_to :action => "index", :project_id => params[:project_id]
    else
      redirect_to url_for({ :controller => 'contracts', :action => 'show', :project_id => @contract.project.identifier, :id => @contract.id })
    end
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

  def contract_params
    params.require(:contract).permit(:description, :agreement_date, :start_date, :end_date, :contract_url,
      :invoice_url, :project_id, :project_contract_id, :purchase_amount, :hourly_rate, :category_id, :is_fixed_price)
  end

  # Allows the user to hide or show locked contracts on contract list pages
  def set_contract_visibility
    # set session variable to the boolean true and false instead of using the string parameter
    if params[:contract_list].present?
      if params[:contract_list][:show_locked_contracts] == "true"
        session[:show_locked_contracts] = true
      else
        session[:show_locked_contracts] = false
      end
    elsif session[:show_locked_contracts].nil?
      # set session variable for first time guests
      session[:show_locked_contracts] = false
    end
  end

end
