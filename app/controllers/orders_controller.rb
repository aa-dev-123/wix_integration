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
    begin
      payload = JWT.decode(request.raw_post, OpenSSL::PKey::RSA.new(ENV['WIX_PUBLIC_KEY']), true, algorithm: 'RS256').first

      event = JSON.parse(payload['data'])
      event_data = JSON.parse(event['data'])

      case event['eventType']
      when "wix.ecom.v1.order_updated"
        order = Order.find_by(external_reference_id: event_data['updatedEvent']['currentEntity']['id'])

        if order.present?
          # changing status of the order
          order.update(status: event_data['updatedEvent']['currentEntity']['fulfillmentStatus'],
            payment_status: event_data['updatedEvent']['currentEntity']['paymentStatus'])
        end
  
        Rails.logger.info("OrderUpdated event received: #{event_data}")
        Rails.logger.info("Instance ID: #{event['instanceId']}")
      else
        Rails.logger.warn("Unknown event type received: #{event['eventType']}")
      end

      head :ok
    rescue => e
      Rails.logger.error("Webhook error: #{e.message}")
      render plain: "Webhook error: #{e.message}", status: :bad_request
    end
  end
end
