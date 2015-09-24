class AddVisibleToCustomizableProductOptions < ActiveRecord::Migration
  def change
    add_column :spree_customizable_product_options, :visible, :boolean, :default => true
  end
end
