Mpd::Application.routes.draw do

  resources :periods, :only => :show, :shallow => true do
		resources :teams, :except => [:index, :new], :shallow => true do
			resources :leaders, :as => 'team_leaders', :only => [:show, :create, :destroy]
			# Assignments
			#resources :team_members, :only => [:show, :create, :destroy]
			member do
				get 'list'
				post 'list'
			end
		end
		resources :groups, :except => [:index, :new], :shallow => true do
			resources :coaches, :as => 'group_coaches', :only => [:show, :create, :destroy]
			# Assignments
			#resources :group_members, :only => [:show, :create, :destroy]
			member do
				get 'list'
				post 'list'
			end
		end
		resources :admins, :as => 'period_admins', :only => [:show, :create, :destroy]
		
		#resources :report_fields
		member do
			get 'show_fields'
			post 'update_fields'
			get 'list'
			post 'list'
		end
	end

	resources :assignments, :except => [:index, :create, :destroy], :shallow => true do
		member do
			delete 'team' # Delete team
			delete 'group' # Delete group
		end
		collection do
			post 'create_team' # Create w/ team
			post 'create_group' # Create w/ group
		end

		resources :pledges, :only => [:index, :create, :destroy] do
			put 'toggle', :on => :member
		end

		resources :reports, :except => [:index]
  	
		resources :goals
	end
  
  resources :users, :except => :index
  
	match 'login' => 'home#login', :via => :get
	match 'login' => 'home#do_login', :via => :post
	match 'logout' => 'home#logout'
	root :to => 'home#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

end
