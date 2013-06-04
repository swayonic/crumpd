class Goal < ActiveRecord::Base
  attr_accessible :assignment_id, :frequency, :amount

  belongs_to :assignment

  @@frequencies = {'0' => 'One-time', '1' => 'Annual', '12' => 'Monthly'}

  def self.pct(a, t)
    (t and t > 0 and a) ? (Float(a)*100/t).round(2) : nil
  end

  def self.title(f)
    return @@frequencies[String(f)] || "#{f} times yearly"
  end

  def title
    return Goal.title(frequency)
  end

  # The default goals - valid for all stint/intern assignment
  def self.defaults
    [Goal.new(:frequency => 12), Goal.new(:frequency => 0)]
  end

end
