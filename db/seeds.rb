# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

### Users

User.new(
  :guid => '0A8DB7CB-1677-CD8D-F519-6ED6B4F10CA2',
  :account_number => '000578812',
  :is_admin => true).save
User.new(
  :guid => '0CC11C11-A091-825C-F0BA-A3A89F8C4D4A',
  :account_number => '000522087',
  :first_name => 'Rebecca',
  :preferred_name => 'Becca',
  :last_name => 'Phillips').save
User.new(
  :guid => '5693F5DC-EB25-74D7-50DC-DA6F2E50E7E3',
  :account_number => '000572760',
  :first_name => 'Regina',
  :last_name => 'Clark').save

User.new(:account_number => 't01',
  :first_name => 'Test',
  :last_name => 'Coach').save
 User.new(:account_number => 't02',
  :first_name => 'Test',
  :last_name => 'Leader').save
User.new(:account_number => 't03',
  :first_name => 'Test 1',
  :last_name => 'Member').save
User.new(:account_number => 't04',
  :first_name => 'Test 2',
  :last_name => 'Member').save

### Regions

Region.new(
  :name => 'test',
  :title => 'Test Region').save
Region.new(
  :name => 'RR',
  :title => 'Red River Region').save

### Periods

p = Period.new(
  :year => 2012,
  :keep_updated => false)
p.region = Region.first
p.save

### Groups

g = Group.new(:name => 'Group 1')
g.period = Period.first
g.save

### Coaches

c = GroupCoach.new
c.user = User.find_by_last_name('Coach')
c.group = Group.first
c.save

### Teams

t = Team.new(:name => 'Team 1')
t.period = Period.first
t.save
t = Team.new(:name => 'Team 2')
t.period = Period.first
t.save

### Leaders

l = TeamLeader.new
l.user = User.find_by_last_name('Leader')
l.team = Team.first
l.save

### Assignments

a = Assignment.new
a.user = User.first
a.period = Period.first
a.team = Team.first
a.group = Group.first
a.save
a = Assignment.new
a.user = User.find_by_last_name('Leader')
a.period = Period.first
a.team = Team.first
a.save
a = Assignment.new
a.user = User.find_by_first_name('Test 1')
a.period = Period.first
a.team = Team.first
a.save
a = Assignment.new
a.user = User.find_by_first_name('Test 2')
a.period = Period.first
a.team = Team.find(2)
a.group = Group.first
a.save

### Admins

a = PeriodAdmin.new
a.user = User.find_by_first_name('Regina')
a.period = Period.first
a.save
a = PeriodAdmin.new
a.user = User.find_by_last_name('Phillips')
a.period = Period.first
a.save

### Pledges

a = Assignment.first
p = Pledge.new(
  :name => 'Mom',
  :amount => 100,
  :frequency => 12,
  :is_in_hand => true)
p.assignment = a
p.save
p = Pledge.new(
  :name => 'Dad',
  :frequency => 12,
  :amount => 100)
p.assignment = a
p.save

### Goals

a = Assignment.first
a.goals.new(:frequency => 0, :amount => 17282)
a.goals.new(:frequency => 12, :amount => 2080)
a.save

### Report Fields

p = Period.first
p.report_fields.new(
  :name => 'Account Balance',
  :field_type => 'D',
  :description => 'Current account balance')
p.report_fields.new(
  :name => 'Prayer requests',
  :field_type => 'T')
p.report_fields.new(
  :name => 'MPD Hours',
  :field_type => 'I',
  :description => 'The total amount of time spent on MPD',
  :required => true)
p.save
