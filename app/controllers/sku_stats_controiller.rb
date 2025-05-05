class SkuStatsController < ApplicationController

  def summary
    stats = SkuStat.where(sku: params[:sku])

    render json: {sku: params[:sku], summary: stats.as_json(only: [:week, :total_quantity])}
end