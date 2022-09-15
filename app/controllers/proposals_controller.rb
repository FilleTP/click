class ProposalsController < ApplicationController

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
    @proposal.contact_name = @proposal.customer.name
    @proposal.save!

    # if params[:proposal][:image].present?
    #   params[:proposal][:image].each do |image|
    #     @proposal.photos.attach(io: image, content_type: 'image/jpeg', filename: 'location.jpeg')
    #   end
    # end

    string_creation

    if @proposal.consumptions.count == @proposal.pvgis.count
      # send_propsals(@proposal)
      redirect_to proposal_path(@proposal)
    else
      redirect_to new_proposal_path
      flash[:alert] = 'Sorry'
    end
  end

  def show
    @proposal = Proposal.find(params[:id])
    @pvgis = @proposal.pvgis
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'file_name', template: '/proposals/show.html.erb', layout: 'pdf'
      end
    end

  end

  def update
    image_64 = params[:proposal][:url]
    string = image_64.split(",")[1]
    @proposal = Proposal.find(params[:id])
    @proposal.photos.each do |photo|
      next if photo.filename == "location.jpeg"
      photo.destroy
    end

    @proposal.photos.attach(
      {
              io: StringIO.new(Base64.decode64(string)),
              content_type: 'image/jpeg',
              filename: 'image.jpeg'
             }
    )

    redirect_to "#{full_url_for}.pdf"
  end



  private

  def proposal_params
    params.require(:proposal).permit(:name, :shipping_address, :postal_code, :shipping_city, :shipping_province, :shipping_country, :date, :due_date, :url, :customer_id,  photos: [], consumptions_attributes: [:id, :lat, :lon, :angle, :loss, :slope, :azimuth, :peakpower, :_destroy])
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
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["key"] = ENV["HOLDED_API"]
    request.body = { contactName: proposal.customer.name, date: proposal.date, name: proposal.name}.to_json

    response = http.request(request)

  end
end
