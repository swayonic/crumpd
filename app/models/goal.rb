class Goal < ActiveRecord::Base
  attr_accessible :assignment_id, :frequency, :amount

	belongs_to :assignment

	@@frequencies = {'0' => 'One-time', '1' => 'Annual', '12' => 'Monthly'}

	def self.pct(a, t)
		t > 0 ? (Float(a)*100/t) : 0
	end

	def self.title(f)
		return @@frequencies[String(f)] || "#{f} times yearly"
	end

	def title
		return Goal.title(frequency)
	end

end
