module Spree
  LineItem.class_eval do
    include VatPriceCalculation
    has_many :ad_hoc_option_values_line_items, dependent: :destroy
    has_many :ad_hoc_option_values, through: :ad_hoc_option_values_line_items
    has_many :product_customizations, dependent: :destroy

    def options_text
      str = Array.new
      unless self.ad_hoc_option_values.empty?

        #TODO: group multi-select options (e.g. toppings)
        str << self.ad_hoc_option_values.each { |pov|
          "#{pov.option_value.option_type.presentation} = #{pov.option_value.presentation}"
        }.join(',')
      end # unless empty?

      unless self.product_customizations.empty?
        self.product_customizations.each do |customization|
          price_adjustment = (customization.price == 0) ? "" : " (#{Spree::Money.new(customization.price).to_s})"
          str << "#{customization.product_customization_type.presentation}#{price_adjustment}"
          customization.customized_product_options.each do |option|
            next if option.empty?

            if option.customization_image?
              str << "#{option.customizable_product_option.presentation} = #{File.basename option.customization_image.url}"
            else
              str << "#{option.customizable_product_option.presentation} = #{option.value}"
            end
          end # each option
        end # each customization
      end # unless empty?

      str.join('\n')
    end

    def cost_price
      (variant.cost_price || 0) + ad_hoc_option_values.map(&:cost_price).inject(0, :+)
    end

    def cost_money
      Spree::Money.new(cost_price, currency: currency)
    end

    def price_including_vat_for_line_item(price_options)
      options = price_options.merge(tax_category: self.tax_category)
      gross_amount(price, options)
    end

    def display_price_including_vat_for_line_item(price_options)
      Spree::Money.new(price_including_vat_for_line_item(price_options), currency: currency)
    end

    def update_price
      # Not Tested yet
      self.price = price_including_vat_for_line_item(tax_zone: tax_zone)
    end

  end
end
