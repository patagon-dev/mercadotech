module Spree::Core::SearchkickCustomFilters
  def self.applicable_filters(aggregations)
    es_filters = []

    %w(vendor_id manufacturer).each do |custom_filter|
      es_filters << process_filter(custom_filter, custom_filter.to_sym, aggregations[custom_filter])
    end

    Spree::Taxonomy.filterable.each do |taxonomy|
      es_filters << process_filter(taxonomy.filter_name, :taxon, aggregations[taxonomy.filter_name])
    end

    Spree::Property.filterable.each do |property|
      es_filters << process_filter(property.filter_name, :property, aggregations[property.filter_name])
    end

    Spree::OptionType.filterable.each do |option_type|
      es_filters << process_filter(option_type.filter_name, :option_type, aggregations[option_type.filter_name])
    end

    es_filters.uniq
  end

  def self.process_filter(name, type, filter)
    options = []
    case type
    when :price
      min = filter['buckets'].min_by { |a| a['key'] }
      max = filter['buckets'].max_by { |a| a['key'] }
      options = if min && max
                  { min: min['key'].to_i, max: max['key'].to_i, step: 100 }
                else
                  {}
                end
    when :taxon
      ids = filter['buckets'].map { |h| h['key'] }
      taxons = Spree::Taxon.where(id: ids).order(name: :asc)
      taxons.each { |t| options << { label: t.name, value: t.id } }
    when :property
      values = filter['buckets'].map { |h| h['key'] }
      values.each { |t| options << { label: t, value: t } }
    when :option_type
      values = filter['buckets'].map { |h| h['key'] }
      values.each { |t| options << { label: t, value: t } }
    when :manufacturer
      values = filter['buckets'].map { |h| h['key'] }
      values.each { |t| options << { label: t, value: t } }
    when :vendor_id
      ids = filter['buckets'].map { |h| h['key'] }
      vendors = Spree::Vendor.active.where(id: ids).order(name: :asc)
      vendors.each { |t| options << { label: t.name, value: t.id } }
    end

    {
      name: name,
      type: type,
      options: options
    }
  end

  def self.aggregation_term(aggregation)
    aggregation['buckets'].sort_by { |hsh| hsh['key'] }
  end
end
