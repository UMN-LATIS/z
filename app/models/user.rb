# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  uid              :string(255)
#  context_group_id :integer
#  admin            :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class User < ApplicationRecord
  attr_accessor :email, :first_name, :last_name, :internet_id

  has_many :groups_users, dependent: :destroy
  has_many :groups, through: :groups_users

  belongs_to :default_group,
             foreign_key: 'default_group_id',
             class_name: 'Group'

  belongs_to :context_group,
             foreign_key: 'context_group_id',
             class_name: 'Group'

  validates :context_group, presence: true
  validates :default_group, presence: true
  validates :uid, presence: true
  validate :user_belongs_to_context_group_validation

  before_validation(on: :create) do
    if context_group_id.blank?
      new_context = Group.create(
        name: internet_id,
        description: uid
      )
      groups << new_context
      self.context_group_id = new_context.id
      self.default_group_id = new_context.id
    end
  end

  before_save { generate_token(:remember_token) }

  after_initialize do
    self.first_name = 'Unknown'
    self.last_name = 'Unknown'
    self.email = 'Unknown'
    self.internet_id = 'Unknown'

    load_user_data unless Rails.env.test?
  end

  def reset_context!
    update_context_group!(default_group_id)
  end

  def in_group?(group)
    group.user?(self)
  end

  def load_user_data
    # sets this objects UserData attrs
    me = UserLookupService.new(
      query: uid,
      query_type: 'umndid'
    ).search.first

    if me.present?
      # Sometimes this data is not present
      # so we try for it
      self.first_name = me[:first_name].try(:first)
      self.last_name = me[:last_name].try(:first)
      self.email = me[:email].try(:first)
      self.internet_id = me[:uid].try(:first)
    end
  end

  def user_full_name
    load_user_data unless first_name.present?
    "#{last_name}, #{first_name}"
  end

  def update_context_group_id(group_id)
    self.context_group_id = group_id
  end

  def update_context_group_id!(group_id)
    update_context_group_id(group_id)
    save
  end

  private

  def user_belongs_to_context_group_validation
    unless new_record? || context_group.nil? || in_group?(context_group)
      errors.add(
        :context_group,
        "#{uid} is not a member of #{context_group.name}: #{context_group.description} and so cannot switch contexts to it."
      )
    end
  end

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end
end
