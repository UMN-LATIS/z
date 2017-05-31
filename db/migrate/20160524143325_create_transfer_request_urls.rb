class CreateTransferRequestUrls < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_request_urls, id: false do |t|
      t.references :transfer_request, foreign_key: true
      t.references :url, foreign_key: true
    end
  end
end
