require 'rails_helper'

describe Ak::Updater do
  it "updates resource" do
    expect(Ak::Updater.client).to receive(:update_resource).
      with( "https://act.sumofus.org/rest/v1/petitionpage/8769/", { title: "foo" })


    Ak::Updater.update({
      uri: "https://act.sumofus.org/rest/v1/petitionpage/8769/",
      body: { title: "foo" }
    })
  end
end
