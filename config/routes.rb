Futurescientist::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'accounts/skills_verification' => 'accounts#skills_verification'
  match 'accounts/login' => 'accounts#login'
  match 'accounts/logout' => 'accounts#logout'
  match 'accounts/login_form' => 'accounts#login_form'
  match 'accounts/forgot_password' => 'accounts#forgot_password'
  match 'accounts/forgot_account' => 'accounts#forgot_account'
  match 'sms/receive_sms' => 'sms#receive_sms'
  match 'accounts/changepass' => 'accounts#changepass'
  match 'accounts/changenumber' => 'accounts#changenumber'
  match 'accounts/changelocation' => 'accounts#changelocation'
  match 'accounts/changeskills' => 'accounts#changeskills'
  match 'instructions' => 'problems#instructions'
	match '/accept' => 'problems#accept_problem'

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :accounts
  resources :problems
  resources :skills
  root :to => redirect('/problems')

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
