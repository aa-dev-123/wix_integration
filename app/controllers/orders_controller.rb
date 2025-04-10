class OrdersController < ApplicationController
  def index
    @orders = Orders.all
  end

  def import_projects
    WixService.new.get_orders

    redirect_to orders_path
  end
end
