require 'http'

class GeoAPI
  attr_reader :locations_data,
              :source_data,
              :output,
              :units

  def initialize(opts = {})
    @locations_data = opts[:data]
    @output = opts[:output]
    @units = opts[:units]
    @source_data = get_source_long_lat(opts[:address] || opts[:zip])
  end

  def query
    location_data, min_distance = get_closest_location
    format_result(location_data, min_distance)
  end

  private

  def encode_address(address_string)
    if address_string
      address_string.gsub!(/\s/, '+')
    end
  end

  def prepare_api_url(address)
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}"
  end

  def call_api(url)
    response = HTTP.get(url)
    parsed_response = response.parse
    parsed_response['results'].first['geometry']['location']
  end

  def parse_longitude_latitude(location_data)
    [location_data["lat"], location_data['lng']]
  end

  def get_source_long_lat(address)
    encode_address(address)
    url = prepare_api_url(address)
    response = call_api(url)
    parse_longitude_latitude(response)
  end

  def parse_store_info(location_data)
    store_name = location_data[0]
    store_address = location_data[2..5]
    [store_name, store_address]
  end

  def format_result(location_data, min_distance)
    store_name, store_address = parse_store_info(location_data)

    if units == 'mi'
      min_distance = (min_distance / 1_000 / 1.609344)
    else
      min_distance = (min_distance / 1_000)
    end

    if output == 'text'
      textify(store_name, store_address, min_distance)
    else
      jsonify(store_name, store_address, min_distance)
    end
  end

  def get_closest_location
    min_distance = Float::INFINITY
    store_data = nil

    locations_data.each do |destination_data|
      distance = calculate_distance(destination_data)

      if distance < min_distance
        min_distance = distance
        store_data = destination_data
      end
    end

    [store_data, min_distance]
  end

  def calculate_distance(destination_data)
    earth_radius = 6_371_000
    src_lat = source_data[0].to_f
    src_long = source_data[1].to_f
    dest_lat = destination_data[6].to_f
    dest_long = destination_data[7].to_f

    src_lat_rad = degree_to_radians(src_lat)
    dest_lat_rad = degree_to_radians(dest_lat)

    lat_diff = degree_to_radians(dest_lat - src_lat)
    long_diff = degree_to_radians(dest_long - src_long)

    half_length = Math.sin(lat_diff / 2.0) * Math.sin(lat_diff / 2.0) + Math.cos(src_lat_rad) * Math.cos(dest_lat_rad) * Math.sin(long_diff / 2.0) * Math.sin(long_diff / 2.0)

    angular_distance = 2 * Math.atan2(Math.sqrt(half_length), Math.sqrt(1 - half_length))

    earth_radius * angular_distance
  end

  def degree_to_radians(degree)
    degree * Math::PI / 180
  end

  def textify(store_name, store_address, min_distance)
    store_address = store_address.join(', ')

    puts "<#{store_name}>, located at #{store_address}, is the closest store. It is about #{'%.2f' % min_distance} #{units} away from the user-specified location."
  end

  def jsonify(store_name, store_address, min_distance)
   jsoned = {
      store_name: store_name,
      store_address: store_address[0],
      store_city: store_address[1],
      store_state: store_address[2],
      store_zip: store_address[3],
      distance: "#{'%.2f' % min_distance}",
      units: units
    }

   puts jsoned
   jsoned
  end
end
