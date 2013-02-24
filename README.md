CruMpd


1.	Installation

	a)	Preconditions

		i)	VirtualBox

		ii)	Vagrant

	b)	Clone this repository

	c)	Run `vagrant up`

		i)	Depending on your version of VirtualBox, you may want to choose a different base box in the Vagrantfile

		ii)	This will probably require a system restart after everything finishes installing. Use `vagrant halt` and `vagrant up` instead of `sudo reboot` within an ssh terminal, because you want the vagrant shared drives to be mapped.

	d)	If all the puppet commands complete successfully...

		i)	ssh into the vagrant box

		ii)	Run `cd /vagrant/`

		iii)	Run `bundle install`

		iv)	Run `rake db:migrate`

		v)	Run `rails s`

	e)	View site

		i)	localhost:3000 if using NAT adapter (because port is forwarded)

		ii)	192.168.56.102:3000 if using host-only adapter


2.	Release notes

Began development September 2012

Deployed to Heroku 11/18/2012
