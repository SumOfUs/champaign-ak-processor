class CountryService
  class << self
    def extend_with_local_data(data)
      case data[:params][:country]
      when 'United Kingdom'
        begin
          data[:params][:user_uk_parliamentary_constituency] = GetConstituency.for(data[:params][:postal])
        rescue => e
          Rails.logger.error "Failed to get constituency: #{e.message}"
        end
      end
    end
  end
end
