module Spree
  Price.class_eval do
    
    def display_price_for_length_customized_product
      self.amount = self.variant.product.product_customization_types.first.calculator.min_amount_price
      return nil if amount.nil?
      money.to_s + "/m"
    end

  end
end

