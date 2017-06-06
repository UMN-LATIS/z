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
  attr_accessor :display_name, :internet_id, :display_name_loaded, :email_loaded, :internet_id_loaded

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
    @display_name_loaded = nil
    @internet_id_loaded = nil
  end

  def reset_context!
    update_context_group_id!(default_group_id)
  end

  def in_group?(group)
    group.user?(self)
  end

  def display_name
    if @display_name_loaded.nil?
      load_user_data
    end
    @display_name_loaded
  end

  def email
    if @internet_id_loaded.nil?
      load_user_data
    end
    "#{@internet_id_loaded}@umn.edu"
  end

  def internet_id
    if @internet_id_loaded.nil?
      load_user_data
    end
    @internet_id_loaded
  end


  def load_user_data
    # sets this objects UserData attrs
    me = UserLookup.new(
        query: uid,
        query_type: 'umndid'
    ).search.try(:first)

    @display_name_loaded = 'Unknown'
    @internet_id_loaded = 'Unknown'

    if me.present?
      # Sometimes this data is not present
      # so we try for it
      @display_name_loaded = me[:display_name] || 'Name not available'
      @internet_id_loaded = me[:internet_id] || 'Unknown'
    end
  end

  def update_context_group_id(group_id)
    self.context_group_id = group_id
  end

  def update_context_group_id!(group_id)
    update_context_group_id(group_id)
    save
  end

  def generate_authentication_token
    generate_token(:secret_key)
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
