class Page < ApplicationRecord
  belongs_to :language

  def ak_uid
    ak_slug.blank? ? name : ak_slug
  end
end
