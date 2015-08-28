Deface::Override.new(
  virtual_path: "spree/shared/_products",
  name: "show price for length customized product at product",
  replace: "erb[loud]:contains('display_price(product)')",
  text: "<% if product.product_customization_types.present? && product.product_customization_types.first.calculator.type == 'Spree::Calculator::ProductLength' %>
           <%= product.price_in(current_currency).display_price_for_length_customized_product %>
         <% else %>
           <%= display_price(product) %>
         <% end %>"
)
