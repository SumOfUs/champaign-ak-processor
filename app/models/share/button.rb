class Share::Button < ActiveRecord::Base
  belongs_to :page
  scope :with_page, -> { includes(:page) }
  scope :where_page_is_active, -> { where(pages: {active: true}) }


  def self.ids_of_active_buttons
    with_page.where_page_is_active.ids
  end
end
