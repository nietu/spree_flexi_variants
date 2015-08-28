Deface::Override.new(
  virtual_path: "spree/checkout/_delivery",
  name: "use line item price at delivery for flex product",
  replace: "erb[loud]:contains('display_price(item.variant)')",
  text: "<% if item.line_item.product_customizations.present? %>
           <%= display_price_for_flex_variant(item.line_item) %>
         <% else %>
           <%= display_price(item.variant) %>
         <% end %>"
)
