class AkLanguageUriFinder
  LANGUAGE_MAPPINGS = {
      en: ENV['ENGLISH_URI'],
      de: ENV['GERMAN_URI'],
      fr: ENV['FRENCH_URI'],
      es: ENV['SPANISH_URI'],
      'EN/US': ENV['ENGLISH_URI']
  }

  def self.get_ak_language_uri(language_code)
    LANGUAGE_MAPPINGS[language_code.to_sym]
  end
end
