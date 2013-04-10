class Team < ActiveRecord::Base
  attr_accessible :period_id, :name,
    # Sitrack data
    :sitrack_id, :sitrack_name,
    :city, :state, :country, :continent

  belongs_to :period
  has_many :team_leaders, :dependent => :destroy
  has_many :leaders, :through => :team_leaders, :source => :user
  has_many :assignments
  has_many :members, :through => :assignments, :source => :user

  def display_name
    return name if !name.blank?
    return sitrack_name if !sitrack_name.blank?
    return "#{city} Team" if !city.blank?
    return "Team #{sitrack_id}" if !sitrack_id.blank?
    return "Team #{self.id}"
  end

  def can_view?(u)
    return true if u.is_admin
    return true if period.admins.include?(u)
    return true if members.include?(u)
    return false
  end

  def can_edit?(u)
    return true if u.is_admin
    return true if period.admins.include?(u)
    return false
  end

  def can_view_list?(u)
    return true if u.is_admin
    return true if period.admins.include?(u)
    return false
  end

end
