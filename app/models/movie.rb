class Movie < ApplicationRecord
  has_many :bookmarks
  has_many :lists, through: :bookmarks

  validates :title, presence: true
  validates :title, uniqueness: { message: "this title already exists" }
  validates :overview, presence: :true
end
