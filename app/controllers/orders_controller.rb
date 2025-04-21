class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def index
    @orders = Order.all
  end

  def import_orders
    WixService.new.get_orders(Shop.first)

    redirect_to orders_path
  end

  def webhook
  end
end
