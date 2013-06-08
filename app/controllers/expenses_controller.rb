class ExpensesController < ApplicationController
  before_filter :set_project, :authorize, only: [:new, :edit, :update, :create, :destroy]
  before_filter :set_expense, only: [:edit, :update, :destroy]

  def new
    @expense = Expense.new
    load_contracts
  end

  def edit
    load_contracts
  end

  def create
    @expense = Expense.new(params[:expense])

    respond_to do |format|
      if @expense.save
        format.html { redirect_to contract_urlpath(@expense), notice: l(:text_expense_created) }
      else
        load_contracts
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @expense.update_attributes(params[:expense])
        format.html { redirect_to expense_editpath(@expense), notice: l(:text_expense_updated) }
      else
        load_contracts
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    back_to = contract_urlpath(@expense)
    @expense.destroy
    flash[:alert] = "Expense deleted."
    respond_to do |format|
      format.html { redirect_to back_to }
    end
  end

  private

    def contract_urlpath(expense)
      contract = expense.contract
      "/projects/#{contract.project.identifier}/contracts/#{contract.id}?expenses=true"
    end
    
    def expense_editpath(expense)
      "/projects/#{expense.contract.project.identifier}/expenses/#{expense.id}/edit"
    end

    def set_expense
      @expense = Expense.find(params[:id])
    end

    def set_project
      @project = Project.find(params[:project_id])
    end

    def load_contracts
      @contracts = Contract.order("start_date ASC").where(:project_id => @project.id)
    end


end
