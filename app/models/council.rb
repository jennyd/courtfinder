class Council < ActiveRecord::Base
  attr_accessible :name
  validates :name, presence: true, uniqueness: true

  has_many :local_authorities
  has_many :courts, through: :local_authorities

  scope :by_name, -> { order('LOWER(name)') }
  scope :search, ->(query){ where('LOWER(name) like ?', "#{query.downcase}%").limit(10) }
end
