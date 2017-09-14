require 'spec_helper'

parsed_data = [
  ['Freeport', 'SWC SWC Sunrise Hwy & Buffalo St', '248 Sunrise Hwy', 'Freeport', 'NY', '11520-3943', '40.6555849', '-73.5717874', 'Nassau County'],
  ['Crystal', 'SWC Broadway & Bass Lake Rd', '5537 W Broadway Ave', 'Crystal', 'MN', '55428-3507', '45.0521539', '-93.364854', 'Hennepin County']
]

describe GeoAPI do
  it 'sets coordinates for user-specified address / zip', :vcr do
    options = {
      data: parsed_data,
      zip: '11520'
    }

    InputValidator.validate(options)
    geo_api = GeoAPI.new(options)

    expect(geo_api.source_data.size).to eq 2
  end

  it 'outputs correct (closest) location in a user-friendly format', :vcr do
    options = {
      data: parsed_data,
      zip: '11520'
    }

    InputValidator.validate(options)
    geo_api = GeoAPI.new(options)

    expect { geo_api.query }.to output("<Freeport>, located at 248 Sunrise Hwy, Freeport, NY, 11520-3943, is the closest store. It is about 1.20 mi away from the user-specified location.\n").to_stdout
  end

  it 'outputs correct (closest) location in a machine-friendly format (JSON)', :vcr do
    options = {
      data: parsed_data,
      zip: '11520',
      output: 'json'
    }

    InputValidator.validate(options)
    geo_api = GeoAPI.new(options)

    json = {
      :store_name=>'Freeport',
      :store_address=>'248 Sunrise Hwy',
      :store_city=>'Freeport',
      :store_state=>'NY',
      :store_zip=>'11520-3943',
      :distance=>'1.20',
      :units=>'mi'
    }

    json_string = json.to_s << "\n"

    expect { geo_api.query }.to output(json_string).to_stdout
    expect(geo_api.query).to eq json
  end
end
