# CruMpd


## Installation

1. Preconditions
	* VirtualBox
	* Vagrant
2. Clone this repository
3. Run `vagrant up`
	* Depending on your version of VirtualBox, you may want to choose a different base box in the Vagrantfile
	* This will probably require a system restart after everything finishes installing. Use `vagrant halt` and `vagrant up` instead of `sudo reboot` within an ssh terminal, because you want the vagrant shared drives to be mapped.
4. If all the puppet commands complete successfully...
	* ssh into the vagrant box
	* Run `cd /vagrant/`
	* Run `bundle install`
	* Run `rake db:migrate`
	* Run `rails s`
5. View site
	* localhost:3000 if using NAT adapter (because port is forwarded)
	* 192.168.56.102:3000 if using host-only adapter

## Release notes

* Began development September 2012
* Deployed to Heroku 11/18/2012
* Cloned to GitHub 02/24/2013
