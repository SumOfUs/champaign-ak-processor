require 'rails_helper'

describe AkLanguageUriFinder do
  let(:language_codes){
    %w(en, fr, de, es)
  }
  let(:expected_uris) {
    {
        en: ENV['ENGLISH_URI'],
        fr: ENV['FRENCH_URI'],
        de: ENV['GERMAN_URI'],
        es: ENV['SPANISH_URI']
    }
  }

  it 'should be able to find the language URIs' do
    language_codes.each do |language_code|
      expect(AkLanguageUriFinder.get_ak_language_uri(language_code)).to eq(expected_uris[language_code.to_sym])
    end
  end
end
