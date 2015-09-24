module Spree
  Order.class_eval do
    self.register_line_item_comparison_hook(:product_customizations_match)

    # FIXTHIS this is exactly the same it seems as Order Content add to line item.
    #this whole thing needs a refactor!
    def add_variant(variant, quantity = 1, options = {})
      # grab_line_item_by_variant???
      current_item = find_line_item_by_variant(variant, options)
      if current_item
        current_item.quantity += quantity
        current_item.save
      else
        current_item = LineItem.new(quantity: quantity, variant: variant, options: options)

        product_customizations_ids = ( !!options[:product_customizations] ? options[:product_customizations].map{|ids| ids.first.to_i} : [] )
        product_customizations_values = product_customizations_ids.map do |cid|
            ProductCustomization.find(product_customization_type_id: cid)
        end
        current_item.product_customizations = product_customizations_values
        product_customizations_values.each { |product_customization| product_customization.line_item = current_item }
        product_customizations_values.map(&:save) # it is now safe to save the customizations we built

        # find, and add the configurations, if any.  these have not been fetched from the db yet.              line_items.first.variant_id
        # we postponed it (performance reasons) until we actually knew we needed them
        ad_hoc_option_value_ids = ( !!options[:ad_hoc_option_values] ? options[:ad_hoc_option_values] : [] )
        product_option_values = ad_hoc_option_value_ids.map do |cid|
          AdHocOptionValue.find(cid)
        end
        current_item.ad_hoc_option_values = product_option_values

        offset_price = product_option_values.map(&:price_modifier).compact.sum + product_customizations_values.map {|product_customization| product_customization.price(variant)}.sum

        current_item.price = variant.price + offset_price

        self.line_items << current_item
      end
      current_item
    end

    def merge!(order, user = nil)
      # this is bad, but better than before
      order.line_items.each do |other_order_line_item|
        next unless other_order_line_item.currency == currency

        # Compare the line items of the other order with mine.
        # Make sure you allow any extensions to chime in on whether or
        # not the extension-specific parts of the line item match
        current_line_item = self.line_items.detect do |my_li|
          my_li.variant == other_order_line_item.variant && self.line_item_comparison_hooks.all? do |hook|
            self.send(hook, my_li, other_order_line_item.serializable_hash)
          end
        end
        if current_line_item
          current_line_item.quantity += other_order_line_item.quantity
          current_line_item.save!
        else
          other_order_line_item.order_id = self.id
          other_order_line_item.save!
        end
      end
      order.line_items.each do |line_item|
        self.add_variant(line_item.variant, line_item.quantity, {
          ad_hoc_option_values: line_item.ad_hoc_option_value_ids,
          product_customizations: line_item.product_customizations
        })
      end

      self.associate_user!(user) if !self.user && !user.blank?

      updater.update_item_count
      updater.update_item_total
      updater.persist_totals

      # So that the destroy doesn't take out line items which may have been re-assigned
      order.line_items.reload
      order.destroy
    end

    def product_customizations_match(line_item,new_customizations)
      existing_customizations = line_item.product_customizations
      
      if new_customizations.kind_of? ActiveSupport::HashWithIndifferentAccess
        # if there aren't any customizations, there's a 'match'
        return true if existing_customizations.empty? && new_customizations.empty?
        new_product_customizations = new_customizations.slice("product_customizations")["product_customizations"]
        new_product_customizations_ids = []
        pairs = []
        new_product_customizations.each do |npc|
          new_product_customizations_ids << npc.product_customization_type_id
          npc.customized_product_options.each do |values|
            pairs << [values.customizable_product_option_id, values.value.present? ? values.value : values.customization_image.to_s ]
          end
        end
        return false unless existing_customizations.map(&:product_customization_type_id).sort == new_product_customizations_ids.sort 
        new_vals = Set.new pairs
      else
        new_customizations = new_customizations.product_customizations

        # if there aren't any customizations, there's a 'match'
        return true if existing_customizations.empty? && new_customizations.empty?
        # exact match of all customization types?
        return false unless existing_customizations.map(&:product_customization_type_id).sort == new_customizations.map(&:product_customization_type_id).sort

        new_vals = customization_pairs(new_customizations)
      end
  
      # get a list of [customizable_product_option.id,value] pairs
      existing_vals = customization_pairs(existing_customizations)
      # do a set-compare here
      existing_vals == new_vals
    end

    private
      # produces a list of [customizable_product_option.id,value] pairs for subsequent comparison
      def customization_pairs(product_customizations)
        pairs= product_customizations.map(&:customized_product_options).flatten.map do |m|
          [m.customizable_product_option.id, m.value.present? ? m.value : m.customization_image.to_s ]
        end

        Set.new pairs
      end
  end
end
