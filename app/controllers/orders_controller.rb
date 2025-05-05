class OrdersController < ApplicationController
  def create
    ActiveRecord.::Base.transaction do
      order = Order.find_by(external_id: params[:external_id])

      if order.present?
        if order.locked_at.present? || (order.placed_at < (Time.zone.now - 15.minutes))
          return render json: {
            error: "Order is locked"
          },
          status: :unprocessable_entity

        end

        if params[:line_items].present?
          order.line_items.update_all(original: false)
        end
        
      else
        order = Order.create!(params.except(:line_items))
      end

      params[:line_items].each do |item|
        order.line_items.create!(
          sku: item[:sku],
          quantity: item[:quantity],
          original: true
        )
      end

      RecalculateSkuStatsTask.delay(queue: "default").calculate_sku_stats(params[:line_items].pluck(:sku).flatten.compact.uniq)

      render json: {id: order.id}, status: :ok
    end
  end


  def lock
    ActiveRecord.::Base.transaction do
      order = Order.find(params[:id])

      if order.blank?
        return render json: {error: "Invalid Order Id"}, status: :not_found
      end

      if order.locked_at.present?
        return render json: {error: "Order is already locked"}, status: :unprocessable_entity
      end

      order.update!(locked_at: Time.zone.now)

      RecalculateSkuStatsTask.delay(queue: "default").calculate_sku_stats(params[:line_items].pluck(:sku).flatten.compact.uniq)

      render json: {message: "Order locked Successfully"}, status: :ok
    end
  end
end
