require 'json'
require 'rails_helper'

describe ActionkitPageParser do
  let(:ak_json) { '{
    "actions": "/rest/v1/importaction/?page=3308",
    "allow_multiple_responses": true,
    "created_at": "2015-05-25T19:22:51",
    "default_source": "",
    "fields": {},
    "followup": null,
    "goal": null,
    "goal_type": "actions",
    "hidden": false,
    "hosted_with": "/rest/v1/hostingplatform/1/",
    "id": 3308,
    "language": "/rest/v1/language/100/",
    "list": "/rest/v1/list/1/",
    "multilingual_campaign": null,
    "name": "controlshift-company-stop-selling-bee-killing-pestices-11",
    "never_spam_check": false,
    "notes": "",
    "recognize": "once",
    "required_fields": [],
    "resource_uri": "/rest/v1/importpage/3308/",
    "status": "active",
    "subscribe": true,
    "tags": [
        {
            "name": "ControlShift",
            "resource_uri": "/rest/v1/tag/1405/"
        },
        {
            "name": "sumofus ControlShift",
            "resource_uri": "/rest/v1/tag/1406/"
        }
    ],
    "title": "ControlShift: COMPANY: Stop selling bee-killing pestices",
    "type": "Import",
    "unsubscribe": false,
    "unsubscribe_all": false,
    "updated_at": "2015-05-25T19:22:51",
    "url": ""
}' }
  let(:crm_page) {
    CrmPage.new crm_id: 3308, hidden: false, status: 'active', language: '/rest/v1/language/100/',
                title: 'ControlShift: COMPANY: Stop selling bee-killing pestices',
                resource_uri: '/rest/v1/importpage/3308/', type: 'Import',
                name: 'controlshift-company-stop-selling-bee-killing-pestices-11'
  }
  let(:ak_parser) { ActionkitPageParser }
  let(:message_json) {
    {
        page: {
            title: 'A test petition page from Champaign',
            slug: 'a-test-petition-page-from-champaign',
            active: true,
            language: '/rest/v1/language/100',
            widgets: [
                {
                    widget_type: 'petition',

                },
                {
                    widget_type: 'donation'
                }
            ]
        }
    }.to_json
  }
  let(:created_petition_page) {
    CrmPage.new title: 'A test petition page from Champaign', language: '/rest/v1/language/100',
                status: 'active', hidden: false, name: 'a-test-petition-page-from-champaign-petition',
                type: 'Petition'
  }
  let(:created_donation_page) {
    CrmPage.new title: 'A test petition page from Champaign', language: '/rest/v1/language/100',
                status: 'active', hidden: false, name: 'a-test-petition-page-from-champaign-donation',
                type: 'Donation'
  }
  let(:message_pages) {
    [created_petition_page, created_donation_page]
  }


  it 'should correctly parse AK JSON' do
    expect(ak_parser.parse_from_actionkit(ak_json)).to eq(crm_page)
  end

  it 'should correctly convert already parsed AK JSON' do
    converted_json = JSON.parse(ak_json)
    expect(ak_parser.parse_from_actionkit(converted_json)).to eq(crm_page)
  end

  it 'should correctly create a single page from a message' do
    expect(ak_parser.parse_from_message(message_json)).to eq(message_pages)
  end
end