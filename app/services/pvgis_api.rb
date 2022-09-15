class PvgisApi
  def initialize(string, proposal)
    @string = string
    @proposal = proposal
  end

  def call_pvgis
    @response = Faraday.get 'https://re.jrc.ec.europa.eu/api/v5_2/PVcalc?' + "lat=#{@string.lat}" + "&lon=#{@string.lon}" + "&peakpower=#{@string.peakpower}" + "&angle#{@string.angle}" + "&outputformat=json" + "&loss=#{@string.loss}" + "&slope=#{@string.slope}" + "&azimuth=#{@string.azimuth}."
  end

end
