module Spree
  BaseHelper.module_eval do

    def display_price_for_flex_variant(current_line_item)
      current_line_item.
      display_price_including_vat_for_line_item(current_price_options).
      to_html
    end

    def current_currency_symbol
      symbol = Spree::Money.new(1, currency: current_currency).to_s
      symbol = symbol.gsub(/,./, "").gsub(/\d\s?/, "")
      return symbol # symbol only
    end  

  end
end
