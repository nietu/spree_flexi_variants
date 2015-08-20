module Spree
  class Calculator::ProductLength < Calculator
    preference :multiplier, :decimal, :default=>0.1 # equals 10€/m

    preference :min_amount, :integer, :default=>100
    preference :max_amount, :integer, :default=>30000

    def self.description
      "Product Length Calculator"
    end

    def self.register
      super
      ProductCustomizationType.register_calculator(self)
    end

    def create_options
      # This calculator knows that it needs one CustomizableOption named length
      [
       CustomizableProductOption.create(:name=>"length", :presentation=>"length")
      ]
    end

    def compute(product_customization, variant=nil)
      return 0 unless valid_configuration? product_customization

      # expecting only one CustomizedProductOption
      opt = product_customization.customized_product_options.detect {|cpo| cpo.customizable_product_option.name == "length" } rescue 0.0
      opt.value.to_i * preferred_multiplier
    end

    def valid_configuration?(product_customization)
      true
    end
    
    def min_amount_price
      preferred_multiplier * preferred_min_amount
    end
  end
end
