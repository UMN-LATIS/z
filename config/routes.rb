Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # http://guides.rubyonrails.org/routing.html

  # Handle Auth
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create'

  get '/auth/failure' do
    redirect '/'
  end

  root 'home#index'
  get 'shortener', to: 'urls#index'

  # This will allow us to run the meat of the app at z.umn.edu/shortener and
  # assume that all other z.umn.edu/:keywords are requests for short urls.
  scope '/shortener' do
    # /	home	index	get
    get '/home', to: 'home#index'

    # / user_lookup/:search_terms
    get '/user_lookup/:search_terms', to: 'user_lookup#index'



    # faq	faq	index	get
    get '/faq', to: 'faq#index'

    # sessions sessions destroy get
    get '/signin', to: 'sessions#new'
    get '/signout', to: 'sessions#destroy'

    # urls	urls	index	get
    # urls/:id	urls	show	get
    # urls/:id/edit	urls	edit	get
    # urls/new	urls	new	get
    # urls/update	urls	update	post
    # urls/create	urls	create	put
    # urls/destroy	urls	destroy	delete
    resources :urls do
      get 'keyword_filter/(:destination)/(:keyword)',
          on: :collection,
          to: 'urls#keyword_filter',
          as: 'keyword_filter'
      get 'download_qrcode', to: 'url_barcodes#show'
      get 'csv/:duration/:time_unit', to: 'url_csvs#show'
      get 'csv/:duration/:time_unit',
          on: :collection,
          to: 'url_csvs#show',
          as: 'csv'
    end

    # transfer_requests	transfer_requests	index	get
    # transfer_requests/new	transfer_requests	new	post
    # transfer_requests/confirm	transfer_requests	confirm	post
    # transfer_requests/create	transfer_requests	create	put
    # transfer_requests/:id/:key/:status	transfer_requests	update	post
    # transfer_requests/:id/show	transfer_requests	show	get
    # transfer_requests/:id/edit	transfer_requests	edit	get
    # transfer_requests/:id/withdraw	transfer_requests	destroy	delete
    resources :transfer_requests do
      post 'confirm', on: :member
    end

    resources :move_to_group, only: [:new, :create]

    # groups	groups	index	get
    # groups/:id	groups	show	get
    # groups/:id/edit	groups	edit	get
    # groups/new	groups	new	get
    # groups/update	groups	update	post
    # groups/create	groups	create	put
    # groups/destroy	groups	destroy	delete
    resources :groups do
      # groups/:id/members	group_memberships	index	get
      # groups/:id/members/new	group_memberships	new	get
      # groups/:id/members/create	group_memberships	create	put
      # groups/:id/members/destroy	group_memberships	destroy	delete
      resources :members, only: [:index, :new, :create, :destroy], controller: 'group_memberships' do
          get 'new/:search_terms', to: 'group_memberships#new', on: :collection
      end
    end

    # users/:id/show	user	show	put
    resources :users, only: [:show]
    resources :lookup_users, only: [:index]
    # api_keys	api_keys	index	get
    # api_keys/new	api_keys	new	get
    # api_keys/:id	api_keys	show	get
    # api_keys/:id/update	api_keys	update	post
    # api_keys/create	api_keys	create	put
    # api_keys/destroy	api_keys	destroy	delete
    resources :api_keys, only: [:index, :new, :show, :update, :create, :destroy]

    # group_context/update	group_context	show	get
    resources :group_context, only: [:show]

    namespace :admin do
      # admin/transfer_requests/	admin::transfer_requests	index	get
      # admin/transfer_requests/new	admin::transfer_requests	new	post
      # admin/transfer_requests/confirm	admin::transfer_requests	confirm	post
      # admin/transfer_requests/create	admin::transfer_requests	create	put
      # admin/transfer_requests/:id/show	admin::transfer_requests	show	get
      resources :transfer_requests, only: [:index, :new, :create, :show] do
        post 'confirm', on: :member
      end

      # admin/urls/:search	admin::urls	index	get
      # admin/urls/:id	admin::urls	show	get
      # admin/urls/update	admin::urls	update	post
      # admin/urls/delete	admin::urls	destroy	delete
      # admin/urls/create	admin::urls	create	put
      resources :urls, only: [:index, :edit, :show, :update, :destroy, :create] do
        get 'csv/:duration/:time_unit',
            on: :collection,
            to: 'url_csvs#show',
            as: 'csv'
      end

      # admin/members/:search	admin::members	index	get
      # admin/members/:id	admin::members	show	get
      # admin/members/delete	admin::members	destroy	delete
      # admin/members/create	admin::members	create	put
      resources :members, only: [:index, :new, :create, :destroy], controller: 'members' do
        get 'new/:search_terms', to: 'members#new', on: :collection
      end

      # admin/admins	admin::admins	index	get
      # admin/admins/delete	admin::admins	destroy	delete
      # admin/admins/create	admin::admins	create	put
      resources :admins, only: [:index, :destroy, :create]
    end
  end

  # /:keyword	redirect index	get
  get '/*keyword', to: 'redirect#index'
end
