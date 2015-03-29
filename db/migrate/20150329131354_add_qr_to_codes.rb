class AddQrToCodes < ActiveRecord::Migration
  def change
  	add_column :codes, :qrcode_uid,  :string
	add_column :codes, :qrcode_name, :string
  end
end
