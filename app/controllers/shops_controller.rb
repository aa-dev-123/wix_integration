class ShopsController < ApplicationController
  def index
    @shops = Shop.all
  end

  def show
    @shop = Shop.find(params[:id])
  end

  def import_orders
    @shop = Shop.find(params[:id])
    WixService.new(@shop).get_orders

    redirect_to orders_path
  end

  def import_projects
    @shop = Shop.find(params[:id])
    WixService.new(@shop).get_products

    redirect_to projects_path
  end
end
