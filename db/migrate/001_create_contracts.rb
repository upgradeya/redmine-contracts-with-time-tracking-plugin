class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string    :title
      t.text      :description
      t.datetime  :start_date
      t.datetime  :end_date
      t.datetime  :agreement_date
      t.decimal   :hourly_rate 
      t.decimal   :purchase_amount, :precision => 16, :scale => 2
      t.string    :contract_url
      t.string    :invoice_url
      t.integer   :project_id
    end
  end
end
