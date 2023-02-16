module Spree::Search::SearchkickDecorator
  def aggregations
    fs = super

    fs += [:manufacturer, :vendor_id]
    fs
  end

  def where_query
    where_query = super
    where_query[:in_stock] = true
    where_query[:vendor_id] = Spree::Vendor.active.pluck(:id)
    where_query[:store_ids] = current_store_id if current_store_id
    where_query[:created_at] = { gte: created_at, lte: Date.today } if created_at
    where_query
  end

  def sorted
    order_params = super

    case sorting
    when 'price_desc'
      order_params[:price] = :desc
    when 'price_asc'
      order_params[:price] = :asc
    end

    order_params
  end

  def prepare(params)
    super
    @properties[:current_store_id] = params[:current_store_id]
    @properties[:created_at] = params[:created_at]
    @properties[:sorting] = params[:sort_by]
  end

end

::Spree::Search::Searchkick.prepend(Spree::Search::SearchkickDecorator)
