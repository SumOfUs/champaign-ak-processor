class CountryService
  class << self
    def extend_with_local_data(data)
      case data[:params][:country]
      when 'United Kingdom'
        begin
          constituency = GetConstituency.for(data[:params][:postal])
          if constituency
            data[:params][:user_uk_parliamentary_constituency] = constituency
          end
        rescue => e
          Rails.logger.error "Failed to get constituency: #{e.message}"
        end
      end
    end
  end
end
