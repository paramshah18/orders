class RecalculateSkuStatsTask
  

  def calculate_sku_stats(skus)
    to_date = Time.zone.now.beginning_of_day.beginning_of_week - 1.day
    from_date = to_date - 3.weeks
    query = LineItem.where(sku: sku, original: true).joins(:order).where(orders: {placed_at: from_date.beginning_of_week..to_date.end_of_week}).group(:sku).group("to_char(orders.placed_at, 'YYYY- \"W\"IW')").sum(:quantity).select(:sku).select("to_char(orders.placed_at, 'YYYY- \"W\"IW') as week")

    query.each do |(sku, week), total_quantity|
      SkuStat.upsert(
        {
          sku: sku,
          week: week,
          total_quantity: total_quantity
        },
        unique_by: %i(sku week)
      )
    end
    
  end
  
end