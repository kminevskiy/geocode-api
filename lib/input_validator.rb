module InputValidator
  def self.validate(input)
    verify_address(input)
    set_defaults(input)
    verify_output_format(input)
    verify_metrics_format(input)
  end

  private

  def self.verify_address(input)
    if !input[:address] && !input[:zip]
      puts 'Please provide an address or zip code.'
      exit(1)
    elsif input[:zip].to_i == 0
      puts 'Please provide a valid zip code.'
      exit(1)
    end
  end

  def self.verify_output_format(input)
    output_format = input[:output].downcase

    unless output_format == 'text' || output_format == 'json'
      input[:output] = 'text'
    end
  end

  def self.verify_metrics_format(input)
    metrics_format = input[:units].downcase

    unless metrics_format == 'mi' || metrics_format == 'km'
      input[:units] = 'mi'
    end
  end

  def self.set_defaults(input)
    input[:units] = 'mi' if !input[:units]
    input[:output] = 'text' if !input[:output]
  end
end
