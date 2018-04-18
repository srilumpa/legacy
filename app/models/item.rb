class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  field :ref, type: String
  field :description, type: String
  field :location, type: String
  field :locked, type: Boolean, default: false
  field :locked_at, type: Time

  mount_uploader :image, ImageUploader

  has_and_belongs_to_many :users

  validates :ref, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  default_scope ->{ order_by(ref: :asc) }

  def to_s
    ref
  end

  def lock!
    self.locked = true
    self.locked_at = Time.now
    self.save!
  end

  def unlock!
    self.locked = false
    self.locked_at = nil
    self.save!
  end
end
