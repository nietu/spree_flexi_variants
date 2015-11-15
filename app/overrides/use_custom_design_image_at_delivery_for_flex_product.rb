Deface::Override.new(
  virtual_path: "spree/checkout/_delivery",
  name: "use custom_design_image at delivery for flex product",
  replace: "erb[loud]:contains('mini_image(item.variant)')",
  text: '<% if item.line_item.design_id.present? %>
           <% item.line_item.design.update_cachedthumb if item.line_item.design.thumbnail_expired %>
           <%= image_tag(item.line_item.design.cachedthumb, height: "48", width: "48")%>
         <% else %>
           <%= mini_image(item.variant) %>
         <% end %>'
)
