require 'spec_helper'

valid_options = {
  zip: 94117
}

describe InputValidator do
  context 'with valid input' do
    let!(:validator) { InputValidator.validate(valid_options) }

    it 'sets the default output format' do
      expect(valid_options[:output]).to eq 'text'
    end

    it 'sets miles as a default distance measure' do
      expect(valid_options[:units]).to eq 'mi'
    end
  end

  context 'with invalid input' do
    it 'gracefully exits the program if no zip code or address has been provided' do
      invalid_options = { output: 'mi' }

      begin
        InputValidator.validate(invalid_options)
      rescue SystemExit => e
        expect(e.status).to eq 1
      end
    end

    it 'reverts to correct default value if incorrect metric value has been provided' do
      invalid_options = { zip: 89117, output: 'something scarry' }

      InputValidator.validate(invalid_options)

      expect(invalid_options[:output]).to eq 'text'
    end


    it 'reverts to correct default value if incorrect output value has been provided' do
      invalid_options = { zip: 89117, units: 'martian nautical leagues' }

      InputValidator.validate(invalid_options)

      expect(invalid_options[:units]).to eq 'mi'
    end
  end
end
