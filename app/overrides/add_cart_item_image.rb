Deface::Override.new(
  virtual_path: "spree/orders/_line_item",
  name: "converted_cart_item_image",
  replace: "[data-hook='cart_item_image'], #cart_item_image[data-hook]",
  partial: "spree/orders/cart_item_image"
)

Deface::Override.new(
  virtual_path: "spree/shared/_order_details",
  name: "converted_order_item_image",
  replace: "[data-hook='order_item_image'], #order_item_image[data-hook]",
  partial: "spree/orders/order_item_image"
)
