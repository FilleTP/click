require 'uri'
require 'net/http'
require 'openssl'

class CustomersController < ApplicationController

  def index
    get_customers
    #current_customers_holded???
    #@customers == current_customers_holded
    @customers = Customer.all
    @customers = Customer.by_recently_created if params[:order_by_date].present?
    @customers = Customer.by_name if params[:order_by_name].present? && @customers.all.pluck(:name).uniq.length > 1
    if params[:order_by_proposal].present?
      @customers = filter_proposal_amount(params[:order_by_proposal])
    end
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def new
    @customer = Customer.new
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    @customer.update(customer_params)
    update_customers(@customer, @customer.customer_id)
    redirect_to customer_path(@customer)
  end

  def create
    @customer = Customer.new(customer_params)
    send_customers(@customer)
    @customer.customer_id = @holded_id
    if @customer.save
      redirect_to customer_path(@customer)
    else
      render :new
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    delete_customer(@customer.customer_id)
    redirect_to customers_path
  end


private

def customer_params
  params.require(:customer).permit(:name, :code, :email, :mobile, :phone, :customer_id)
end

  def filter_proposal_amount(arg)
    counts = Customer.all.left_joins(:proposals).group("customers.id").count("proposals.id")
    hash = {}
    counts.each do |key, value|
      hash[key] = [Customer.find(key), value]
    end
    if arg == "1"
      @sorted = hash.sort_by { |key, value| value[1] }
    else
      @sorted = hash.sort_by { |key, value| value[1] }.reverse
    end
    @customers = @sorted.map { |x| x[1][0] }
  end

  def get_customers

    url = URI("https://api.holded.com/api/invoicing/v1/contacts")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]

    response = http.request(request)
    #if not match delete
    #by name

    customers = JSON.parse(response.read_body)
      customers.each do |customer|
        unless Customer.where(name: customer['name']).exists?
        Customer.create(
          name: customer["name"],
          code: customer["code"],
          email: customer["email"],
          mobile: customer["mobile"],
          phone: customer["phone"],
          customer_id: customer["id"]
        )
        end
      end
  end

  def send_customers(customer)

    url = URI("https://api.holded.com/api/invoicing/v1/contacts")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]
    request.body = { name: customer.name, code: customer.code, email: customer.email, mobile: customer.mobile, phone: customer.phone }.to_json
    response = http.request(request)
    parsed = JSON.parse(response.body)
    @holded_id = parsed["id"]

  end

  def update_customers(customer, id)

    url = URI("https://api.holded.com/api/invoicing/v1/contacts/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Put.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]
    request.body = { name: customer.name, code: customer.code, email: customer.email, mobile: customer.mobile, phone: customer.phone }.to_json
    response = http.request(request)

  end

  def delete_customer(id)
    url = URI("https://api.holded.com/api/invoicing/v1/contacts/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Accept"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]

    response = http.request(request)

  end

  def current_customers_holded
    #always check the current state = compare to the DB
    #if not same remove instances from DB
  end
end
