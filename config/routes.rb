Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # http://guides.rubyonrails.org/routing.html

  root 'urls#index'
  get 'shortener', to: 'urls#index'

  # This will allow us to run the meat of the app at z.umn.edu/shortener and
  # assume that all other z.umn.edu/:keywords are requests for short urls.
  scope '/shortener' do
    # /	home	index	get
    get '/home', to: 'home# index'

    # faq	faq	index	get
    get '/faq', to: 'faq# index'

    # urls	urls	index	get
    # urls/:id	urls	show	get
    # urls/:id/edit	urls	edit	get
    # urls/new	urls	new	get
    # urls/update	urls	update	post
    # urls/create	urls	create	put
    # urls/destroy	urls	destroy	delete
    resources :urls

    # transfer_requests	transfer_requests	index	get
    # transfer_requests/new	transfer_requests	new	post
    # transfer_requests/confirm	transfer_requests	confirm	post
    # transfer_requests/create	transfer_requests	create	put
    # transfer_requests/:id/:key/:status	transfer_requests	update	post
    # transfer_requests/:id/show	transfer_requests	show	get
    # transfer_requests/:id/withdraw	transfer_requests	destroy	delete
    resources :transfer_requests, except: :edit do
      post 'confirm', on: :member
    end

    # groups	groups	index	get
    # groups/:id	groups	show	get
    # groups/:id/edit	groups	edit	get
    # groups/new	groups	new	get
    # groups/update	groups	update	post
    # groups/create	groups	create	put
    # groups/destroy	groups	destroy	delete
    resources :groups

    # members	group_memberships	index	get
    # members/new	group_memberships	new	get
    # members/create	group_memberships	create	put
    # members/destroy	group_memberships	destroy	delete
    resources :members, only: [:index, :new, :create, :destroy]

    # users/:id/show	user	show	put
    resources :users, only: [:show]

    # api_keys	api_keys	index	get
    # api_keys/new	api_keys	new	get
    # api_keys/:id	api_keys	show	get
    # api_keys/:id/update	api_keys	update	post
    # api_keys/create	api_keys	create	put
    # api_keys/destroy	api_keys	destroy	delete
    resources :api_keys, only: [:index, :new, :show, :update, :create, :destroy]

    # group_context/update	group_context	update	put
    resources :group_context, only: [:update]

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
      resources :urls, only: [:index, :show, :update, :destroy, :create]

      # admin/admins	admin::admins	index	get
      # admin/admins/delete	admin::admins	destroy	delete
      # admin/admins/create	admin::admins	create	put
      resources :admins, only: [:index, :destroy, :create]
    end
  end

  # /:keyword	redirect index	get
  get '/*keyword', to: 'redirect#index'
end
