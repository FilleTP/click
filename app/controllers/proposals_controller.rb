require 'uri'
require 'net/http'
require 'openssl'

class ProposalsController < ApplicationController
  before_action :set_proposal, only: %i[show edit update destroy]

  def index
    @proposals = Proposal.all
    @proposals = Proposal.global_search(params[:query]) if params[:query].present?
    @proposals = Proposal.by_recently_created if params[:order_by_date].present?
    @proposals = Proposal.by_name if params[:order_by_name].present? && @proposals.all.pluck(:name).uniq.length > 1
    @proposals = Proposal.by_customer if params[:order_by_customer].present? && @proposals.joins(:customer).pluck("customers.name").uniq.length > 1

    # parse the JSON objects
    # @proposals.each do |proposal|
    # objects = JSON.parse(proposal.object.items)
    # proposal.object = objects
    # end
  end

  def new
    @proposal = Proposal.new
  end

  def create
    @proposal = Proposal.new proposal_params
    @proposal.date = Date.today
    unless @proposal.consumptions.empty?
      set_coordinates(@proposal)
      if @proposal.consumptions.first.lat != nil
        if @proposal.save
          string_creation
          if @proposal.consumptions.count == @proposal.pvgis.count
            send_propsals(@proposal)
            redirect_to proposal_path(@proposal)
          else
            flash[:alert] = 'Please make sure string is correctly filled in'
            render new_proposal_path
          end
        else
          flash[:alert] = 'Please fill in all the fields'
          render new_proposal_path
        end
      else
        flash[:alert] = 'Please make sure address is correct'
        render new_proposal_path
      end
    else
      flash[:alert] = 'Please add a string'
      render new_proposal_path
    end
  end

  def destroy
    @proposal.destroy
    delete_proposal(@proposal.holded_id)
    redirect_to proposals_path
  end

  def show
    @pvgis = @proposal.pvgis
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'file_name', template: '/proposals/show.html.erb', layout: 'pdf'
      end
    end

  end

  def edit
  end

  def update
    @proposal.update(proposal_params)
    update_proposal(@proposal, @proposal.holded_id)

    if params[:proposal][:url]
      image_64 = params[:proposal][:url]
      string = image_64.split(",")[1]
      @proposal.graph_photo.destroy if @proposal.graph_photo.attached?

      @proposal.graph_photo.attach(
        {
                io: StringIO.new(Base64.decode64(string)),
                content_type: 'image/jpeg',
                filename: 'image.jpeg'
              }
      )
      redirect_to "#{full_url_for}.pdf"
    else
      unless params["consumption_attributes"] == nil
        set_coordinates(@proposal)
      end
      redirect_to proposal_path(@proposal)
    end
  end



  private

  def set_proposal
    @proposal = Proposal.find(params[:id])
  end

  def set_coordinates(proposal)
    results = Geocoder.search("#{@proposal.shipping_address}, #{@proposal.postal_code}, #{@proposal.shipping_city}, #{@proposal.shipping_country}")
    unless results.empty?
      @proposal.consumptions.each do |consumption|
        consumption.lat = results.first.coordinates[0]
        consumption.lon = results.first.coordinates[1]
      end
    end
  end


  def proposal_params
    params.require(:proposal).permit(:name, :shipping_address, :postal_code, :shipping_city, :shipping_province, :shipping_country, :date, :due_date, :customer_id,  :building_photo, consumptions_attributes: [:id, :lat, :lon, :angle, :loss, :slope, :azimuth, :peakpower, :_destroy])
  end

  # def pvgisdata_params
  #   params.require(:proposal).permit(params["proposal"]["pvgisdata"])
  # end

  def string_creation
    @proposal.consumptions.each do |pvgi|

      response_string = PvgisApi.new(pvgi, @proposal).call_pvgis
      obj = JSON.parse(response_string.body)

      names = %w[string1 string2 string3 string4]

      if obj['status'] == 400
        # redirect_to new_proposal_path

      else
        Pvgi.create!(
          proposal_id: @proposal.id,
          name: names.first,
          month1: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month2: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month3: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month4: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month5: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month6: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month7: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month8: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month9: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month10: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month11: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] },
          month12: { E_d: obj["outputs"]["monthly"]["fixed"][0]["E_d"], E_m: obj["outputs"]["monthly"]["fixed"][0]["E_m"], Hi_d: obj["outputs"]["monthly"]["fixed"][0]["H(i)_d"], Hi_m: obj["outputs"]["monthly"]["fixed"][0]["H(i)_m"], SD_m: obj["outputs"]["monthly"]["fixed"][0]["SD_m"] }
        )
        names.delete_at(0)
      end
    end

  end

  def send_propsals(proposal)

    url = URI("https://api.holded.com/api/invoicing/v1/documents/estimate")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/json'
    request["content-type"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]
    request.body = { dueDate: proposal.due_date.to_time.to_i, contactName: proposal.customer.name, date: Time.now.to_i, name: proposal.name}.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)
    proposal.update(quote_num: parsed["invoiceNum"], holded_id: parsed["id"])

    # @holded_id = parsed["id"]

  end

  def update_proposal(proposal, id)
    url = URI("https://api.holded.com/api/invoicing/v1/documents/estimate/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Put.new(url)
    request["accept"] = 'application/json'
    request["content-type"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]
    request.body = { dueDate: proposal.due_date.to_time.to_i, contactName: proposal.customer.name, date: Time.now.to_i, name: proposal.name}.to_json

    response = http.request(request)
  end

  def delete_proposal(id)
    url = URI("https://api.holded.com/api/invoicing/v1/documents/estimate/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Accept"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]

    response = http.request(request)
  end

end
