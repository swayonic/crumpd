class User < ActiveRecord::Base
  attr_accessible :guid, :account_number, :first_name, :last_name, :preferred_name, :phone, :email, :is_admin, :time_zone, :last_login, :real_id

  scope :has_guid, where("guid IS NOT NULL")
  scope :admin, where(:is_admin => true)

  belongs_to :real_user, :class_name => "User", :foreign_key => :real_id

  has_many :assignments, :dependent => :destroy
  has_many :group_coaches, :dependent => :destroy
  has_many :team_leaders, :dependent => :destroy
  has_many :period_admins, :dependent => :destroy

  has_many :groups_as_member, :through => :assignments, :source => :group, :order => "name"
  has_many :groups_as_coach, :through => :group_coaches, :source => :group, :order => "name"
  has_many :teams_as_member, :through => :assignments, :source => :team, :order => "name"
  has_many :teams_as_leader, :through => :team_leaders, :source => :team, :order => "name"
  has_many :periods_as_admin, :through => :period_admins, :source => :period

  validate do
    self.guid = User.cleanup_guid(self.guid)
    self.account_number = User.cleanup_account_number(self.account_number)

    if !self.guid and !self.account_number
      # Don't allow both to be nil
      self.errors.add(:guid, 'Must set either valid guid or valid account_number')
    end
  end

  validates_each :first_name, :last_name, :preferred_name, :phone, :email do |record, attr, value|
    record[attr] = nil if value.nil? or value.blank?
  end

  validates :email, :format => { 
    :with => /^[_A-Za-z0-9-]+(\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*(\.[A-Za-z]{2,4})$/,
    :allow_nil => true,
    :allow_blank => true, #Overwritten by above validation
    :message => "Invalid format"
    }

  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name), :allow_nil => true

  validates_each :real_id do |record, attr, value|
    if value and User.find_by_id(value) == record
      record.errors.add(:real_id, ' - cannot merge a user into itself.')
    end
  end

  # Turns value into a valid guid or nil
  def self.cleanup_guid(value)
    return nil if value.nil? or value.blank?
    return value if value =~ /^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$/
    return nil
  end

  # Turns value into a valid account_number or nil
  def self.cleanup_account_number(value)
    return nil if value.nil? or value.blank?
    return "00#{$2}#{$3}" if value.strip =~ /^(00|)(\d{7})(S|)$/
    return nil
  end

  def display_name
    f = preferred_name || first_name
    l = last_name
    return "##{account_number}"  if !f and !l
    return l if !f
    return f if !l
    return "#{f} #{l}"
  end

  def sort_name
    f = preferred_name || first_name
    l = last_name
    return "##{account_number}"  if !f and !l
    return l if !f
    return f if !l
    return "#{l}, #{f}"
  end


  # Return all periods with which this user is affiliated
  def all_periods
    res = Array.new
    res.concat periods_as_admin
    res.concat assignments.map{|a| a.period}
    res.concat groups_as_coach.map{|g| g.period}
    #res.concat teams_as_leader.map{|t| t.period}
    return res.uniq
  end
  
  def can_view?(u)
    return true
  end

  def can_edit?(u)
    return true if u.is_admin
    return true if u == self

    for p in all_periods
      return true if p.admins.include?(u)
    end

    return false
  end

  # Can't edit certain fields if they are a part of an updated Period
  def gets_updated?
    for p in all_periods
      return true if p.keep_updated?
    end
    return false
  end

  # Returns true if u can become self
  def can_sudo?(u)
    return true if u.is_admin?
    for p in all_periods
      return true if p.admins.include?(u)
    end

    return false
  end

  def self.autocomplete_help_tip_text
    "This is an autocomplete field. Type in the user's name or account number."
  end

end
