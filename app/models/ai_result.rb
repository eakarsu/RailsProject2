class AiResult < ApplicationRecord
  belongs_to :user

  validates :feature, :input, :output, :model, presence: true
end
