class ZipFormatter
  DEFAULT_ZIP_CODE = ENV['DEFAULT_US_ZIP']

  def self.format(zip)
    # Permit nil values
    return if zip.nil?

    first_five = zip.to_s[0,5]
    is_valid_zip(first_five) ? first_five : DEFAULT_ZIP_CODE
  end

  def self.is_valid_zip(zip)
    # Postal is an integer written as a string and five characters long
    zip =~ /\A\d{5}\Z/
  end
end
