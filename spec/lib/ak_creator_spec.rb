require 'rails_helper'

describe AkCreator do
  let(:hostname) { 'localhost' }
  let(:username) { 'fake_username' }
  let(:password) { 'fake_password' }
  let(:connection) {ActionKitConnector::Connector.new username, password, hostname }

  it 'should initialize the connection' do
    creator = AkCreator.new hostname, username, password
    expect(creator.connection.base_url).to eq(connection.base_url)
    expect(creator.connection.password).to eq(connection.password)
    expect(creator.connection.username).to eq(connection.username)
  end
end
