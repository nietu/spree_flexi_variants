Deface::Override.new(
  virtual_path: "spree/shared/_products",
  name: "show price for length base product at product",
  replace: "span.price",
  partial: "spree/shared/product_price_for_length_based_product"
)
