class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  field :username, type: String, default: ''
  field :valid_user, type: Boolean, default: false
  field :admin, type: Boolean, default: false
  has_and_belongs_to_many :items

  default_scope ->{ order_by(username: :asc) }

  validates :username, presence: true, uniqueness: true

  def to_s
    username || email
  end

  def valid_user?
    valid_user
  end

  def toggle_valid_user!
    self.valid_user = !self.valid_user?
    self.save!
  end

  def admin?
    admin
  end

  def toggle_admin!
    self.admin = !self.admin?
    self.save!
  end

  def status
    return :admin if self.admin?
    return :valid_user if self.valid_user?
    return :guest
  end
end
