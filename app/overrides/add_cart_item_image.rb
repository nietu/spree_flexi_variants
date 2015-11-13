Deface::Override.new(
  virtual_path: "spree/orders/_line_item",
  name: "converted_cart_item_image",
  replace: "[data-hook='cart_item_image'], #cart_item_image[data-hook]",
  partial: "spree/orders/cart_item_image"
)

