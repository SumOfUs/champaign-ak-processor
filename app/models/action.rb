class Action < ApplicationRecord
  belongs_to :page, counter_cache: :action_count
  belongs_to :member
end
