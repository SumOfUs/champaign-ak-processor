require 'rails_helper'


describe Share::Button do
  describe '.ids_of_active_buttons' do
    subject {described_class.ids_of_active_buttons }

    let!(:active_page)     { Page.create(title: 'Foo', slug: 'foo', active: true) }
    let!(:inactive_page)   { Page.create(title: 'Foo', slug: 'foo', active: false) }
    let!(:active_button)   { Share::Button.create(page: active_page) }
    let!(:inactive_button) { Share::Button.create(page: inactive_page) }

    it 'returns ids for active buttons' do
      expect(subject).to match_array([active_button.id])
    end
  end
end

