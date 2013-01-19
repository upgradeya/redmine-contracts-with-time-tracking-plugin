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
  end

  def create
    @contract = Contract.new(params[:contract])
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
		@members= []
		@time_entries.each { |entry| @members.append(entry.user) unless @members.include?(entry.user) }
  end

  def edit
    @contract = Contract.find(params[:id])
    @projects = Project.all
  end

  def update
    @contract = Contract.find(params[:id])
    if @contract.update_attributes(params[:contract])
      flash[:notice] = l(:text_contract_updated)
      redirect_to :action => "show", :id => @contract.id 
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
		flash[:error] = l(:text_hours_over_contract, :hours_over => l_hours(-1 * @contract.hours_remaining)) unless @contract.hours_remaining >= 0
    redirect_to "/projects/#{@contract.project.id}/contracts/#{@contract.id}" 
  end

  private

  def find_project
    #@project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id]) 
  end

end
