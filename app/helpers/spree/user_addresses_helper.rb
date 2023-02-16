module Spree
  module UserAddressesHelper
    def address_county(form, state, country)
      state ||= form.object.state
      counties = if state
                   state&.counties&.order(:name)
                 elsif country && country.states.any?
                   country.states.where(abbr: 'RM').take&.counties&.order(:name) || []
                 end
      have_counties = counties.present?
      county_elements = [
        form.collection_select(:county_id, have_counties ? counties : {},
                               :id, :name,
                               { include_blank: 'Seleccionar Comuna' },
                               { class: have_counties || form.object.require_county? ? 'form-control required spree-flat-select' : 'form-control spree-flat-select',
                                 disabled: !have_counties, required: have_counties }) +
          form.text_field(:county_name,
                          class: !have_counties || form.object.require_county? ? 'form-control required d-none' : 'form-control d-none',
                          disabled: have_counties) +
          image_tag('arrow.svg', class: 'position-absolute spree-flat-select-arrow')
      ].join.gsub('"', "'").gsub("\n", '')

      content_tag(:noscript, form.text_field(:county_name, class: 'required')) +
        javascript_tag("document.write(\"<span class='d-block position-relative'>#{county_elements.html_safe}</span>\");")
    end

    def user_address_state(form, country, _address_id = 'b')
      country ||= Spree::Country.find(Spree::Config[:default_country_id])
      have_states = country.states.any?
      default_selected = { selected: form.object.state&.id || country.states.where(abbr: 'RM').pluck(:id) }

      state_elements = [
        form.collection_select(:state_id, country.states.order(:name),
                               :id, :name,
                               default_selected,
                               class: have_states ? 'required form-control spree-flat-select' : 'd-none',
                               disabled: !have_states) +
          form.text_field(:state_name, class: !have_states ? 'required' : 'd-none', disabled: have_states) +
          image_tag('arrow.svg', class: 'position-absolute spree-flat-select-arrow')
      ].join.tr('"', "'").delete("\n")

      content_tag(:noscript, form.text_field(:state_name, class: 'required')) +
        javascript_tag("document.write(\"<span class='d-block position-relative'>#{state_elements.html_safe}</span>\");")
    end

    def address_company_field(form, method, address_id = 'b', &handler)
      content_tag :p, id: [address_id, method].join, class: 'form-group checkout-content-inner-field' do
        if handler
          yield
        else
          method_name = I18n.t("activerecord.attributes.spree/address.#{method}")
          required = Spree.t(:required)
          max_length = if method == :company_rut
                         nil
                       else
                         method == :company ? 60 : 40
                       end

          form.text_field(method,
                          class: %w[required spree-flat-input].compact,
                          required: true,
                          maxlength: max_length,
                          placeholder: "#{method_name} #{required}")
        end
      end
    end

    def invoice_select_tag(form, method, address_id = 'b', current_store)
      content_tag :p, id: [address_id, method].join, class: 'form-group checkout-content-inner-field' do
        method_name = Spree.t(:invoice_type)
        required = Spree.t(:required)

        if current_store.invoice_types.size > 1

          invoice_types = current_store.invoice_types.map { |i| [Spree.t("invoice_type_#{i}"), i] }
          prompt = { prompt: method_name.upcase }

          selected = if form.object.document_type
                       { selected: form.object.document_type }
                     else
                       current_store.invoice_types.include?('39') ? { selected: '39' } : {}
                     end

          prompt.merge!(selected)
          class_name = 'required'
        else
          invoice_types = [[Spree.t("invoice_type_#{current_store.invoice_types[0]}"), current_store.invoice_types[0]]]
          prompt = {}
          class_name = 'd-none'
        end

        form.select(method,
                    invoice_types,
                    prompt,
                    class: [class_name.to_s, 'spree-flat-input', 'form-control', 'invoice-select'].compact,
                    placeholder: "#{method_name} #{required}")
      end
    end

    def phone_field_tag(form, method, _address_id = 'b')
      method_name = I18n.t("activerecord.attributes.spree/address.#{method}")
      required = Spree.t(:required)
      form.number_field(method,
                        class: %w[required spree-flat-input form-control].compact,
                        required: true,
                        placeholder: "#{method_name} #{required}")
    end

    def street_number_field(form, method, _address_id = 'b')
      method_name = I18n.t("activerecord.attributes.spree/address.#{method}")
      required = Spree.t(:required)
      form.number_field(method,
                        class: %w[required spree-flat-input form-control].compact,
                        required: true,
                        placeholder: "#{method_name} #{required}")
    end
  end
end
