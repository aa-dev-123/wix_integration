class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end

  def import_orders
    WixService.new.get_orders

    redirect_to orders_path
  end
end
