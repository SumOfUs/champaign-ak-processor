require 'spec_helper'
require './app/services/zip_formatter'

describe ZipFormatter do
  it 'returns zip unchanged if already of correct form' do
    expect(
      ZipFormatter.format('10000')
    ).to eq('10000')
  end

  it 'trims zip to 5 chars if over' do
    expect(
      ZipFormatter.format('123456')
    ).to eq('12345')
  end

  it 'returns nil for nil' do
    expect(
      ZipFormatter.format(nil)
    ).to be nil
  end

  it 'returns default zip if zip incorrectly formatted' do
    stub_const("ZipFormatter::DEFAULT_ZIP_CODE", '10000')

    expect(
      ZipFormatter.format('a3bchfy7')
    ).to eq('10000')
  end
end
