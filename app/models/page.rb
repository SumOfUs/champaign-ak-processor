class Page < ApplicationRecord
  belongs_to :language
  has_many :actions
end
