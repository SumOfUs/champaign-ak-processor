class CountryService
  class << self
    def extend_with_local_data(data)
      case data[:params][:country]
      when 'United Kingdom'
        data[:params][:user_uk_parliamentary_constituency] = GetConstituency.for(data[:params][:postal])
      end
    end
  end
end
