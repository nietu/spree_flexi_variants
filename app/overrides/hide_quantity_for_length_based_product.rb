Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "hide quantity for length base product at cart",
  replace: "div.input-group",
  partial: "spree/products/hide_quantity_for_length_based_product"
)
