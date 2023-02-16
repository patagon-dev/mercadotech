require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".
  mount Spree::Core::Engine, at: '/'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  constraint = lambda do |request|
    request.env['warden'].user.present? && request.env['warden'].user.admin?
  end

  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  Spree::Core::Engine.add_routes do
    namespace :admin do
      resources :products do
        get :import_csv_products, on: :collection
        get :update_categories_modal, on: :collection
        patch :update_products_categories, on: :collection
        collection do
          get :update_shipping_category_modal
          get :enable_disable_products_modal
          patch :update_products_shipping_category
          patch :enable_disable_products
        end
      end

      resources :orders, except: [:show] do
        collection do
          get :get_services
          post :create_shipment_delivery
          put :mark_payment_refunded
          delete :remove_shipping_label
        end
        member do
          get :shipment_details
        end

        resources :invoices, only: %i[create index]
        resources :bank_accounts, only: %i[create index new]
        get :generate_pickup_list, on: :collection
        get :generate_purchase_list, on: :collection

        resources :payments do
          member do
            put :make_refund
          end
        end

        put 'return_authorizations/:id/generate_shipping_label' => 'return_authorizations#generate_shipping_label', as: :generate_return_shipping_label
        delete 'return_authorizations/:id/destroy_label' => 'return_authorizations#destroy_label', as: :destroy_label
      end

      resources :vendors do
        member do
          get :payments
          get :shipping
          get :tags
          get :invoice
          get :product_import
          get :vendor_terms
          post :add_tags
          post :add_vendor_term
          delete :remove_tags
          delete :remove_vendor_term
        end
      end

      resources :lists do
        member do
          get :sync_subscribers
        end
      end

    resources :vendor_settings, only: [] do
      collection do
        get :schedule_spider
        get :manage_spider
        get :scraped_item_list
      end
    end

      get 'vendor_settings/payments' => 'vendor_settings#payments'
      get 'vendor_settings/shipping' => 'vendor_settings#shipping'
      get 'vendor_settings/invoice' => 'vendor_settings#invoice'
      get 'vendor_settings/product_import' => 'vendor_settings#product_import'
      get 'vendor_settings/tags' => 'vendor_settings#tags'
      post 'vendor_settings/tags' => 'vendor_settings#add_tag'
      delete 'vendor_settings/tags/delete' => 'vendor_settings#remove_tag'
      get 'vendor_settings/vendor_terms' => 'vendor_settings#vendor_terms'
      post 'vendor_settings/vendor_terms' => 'vendor_settings#add_vendor_term'
      delete 'vendor_settings/vendor_terms/delete' => 'vendor_settings#remove_vendor_term'

      resources :stock_locations do
        get :stock_location_report, on: :member
      end

      devise_scope :spree_user do
        get '/login', to: redirect('/saml/sign_in', status: 302), as: :admin_sign_in
      end

      resources :refund_histories, only: [:update]
    end

    resources :vendors, only: %i[show]
    resources :bank_accounts, except: [:show]

    namespace :api, defaults: { format: 'json' } do
      namespace :v1 do
        resources :orders do
          put :update_reference_numbers, on: :member
        end
        resources :shipments, only: %i[create update] do
          put :update_state, on: :member
        end
        resources :products do
          get :active_products, on: :collection
        end
      end
      resources :reviews, only: [:create]
    end

    # URL for start connection with WebpayWS
    get 'webpay_ws_mall', to: 'webpay_ws_mall#pay', as: :webpay_ws_mall
    # The return URL for confirm transaction
    post 'webpay_ws_mall/confirmation', to: 'webpay_ws_mall#confirmation', as: :webpay_ws_mall_confirmation
    # The success URL
    get 'webpay_ws_mall/success', to: 'webpay_ws_mall#success', as: :webpay_ws_mall_success
    get 'webpay_ws_mall/failure', to: 'webpay_ws_mall#failure', as: :webpay_ws_mall_failure
    # route for relation products
    get '/products/:id/related_products', to: 'products#related_products'

    # route for competitor_prices data
    get '/products/:id/competitor_prices', to: 'products#competitor_prices'

    # Redirect default devise routes to IdP (Keycloak)
    devise_scope :spree_user do
      get '/login', to: redirect('/saml/sign_in', status: 302), as: :sign_in
      get '/signup', to: redirect('/saml/sign_in', status: 302), as: :sign_up
      get '/password/change', to: redirect('/saml/sign_in', status: 302), as: :password_change
      get '/password/recover', to: redirect('/saml/sign_in', status: 302), as: :password_recover
      get '/logout', to: redirect('/saml/signout', status: 302), as: :sign_out
    end

    resources :orders do
      resources :return_authorizations, only: %i[new create show]
    end

    # Webpay Oneclick Mall routes
    scope '/oneclick_mall' do
      get  'pay', to: 'oneclick_mall_payment#pay', as: :oneclick_mall_pay
      get  'subscription', to: 'oneclick_mall_subscription#subscription', as: :oneclick_mall_subscription
      post 'subscribe', to: 'oneclick_mall_subscription#subscribe', as: :oneclick_mall_subscribe
      post 'subscribe_confirmation', to: 'oneclick_mall_subscription#subscribe_confirmation', as: :oneclick_mall_subscribe_confirmation
      get  'subscribe_success', to: 'oneclick_mall_subscription#subscribe_success', as:  :oneclick_mall_subscribe_success
      get  'subscribe_failure', to: 'oneclick_mall_subscription#subscribe_failure', as:  :oneclick_mall_subscribe_failure
      get  'unsubscription', to: 'oneclick_mall_subscription#unsubscription', as: :oneclick_mall_unsubscription
      get 'unsubscribe', to: 'oneclick_mall_subscription#unsubscribe', as: :oneclick_mall_unsubscribe
      get 'success', to: 'oneclick_mall_payment#success',  as:  :oneclick_mall_success
      get 'failure', to: 'oneclick_mall_payment#failure',  as:  :oneclick_mall_failure
    end
    post 'card_subscription', to: 'users#card_subscription', as: :card_subscription
    post 'card_subscription_confirmation', to: 'users#card_subscription_confirmation', as: :card_subscription_confirmation
    post 'card_unsubscription', to: 'users#card_unsubscription', as: :card_unsubscription
    post 'update_card', to: 'users#update_card', as: :update_card

    # newsletter routes
    get '/subscription', to: 'home#subscription'
    get '/unsubscription', to: 'home#unsubscription'
    get '/subcriptionstatus', to: 'home#subcription_status'

    # RouteNotFound Error rediect to '/404'
    match 'mini-profiler-resources/*path', to: 'errors#not_found', code: 404, via: :all

    %w(404 422 500).each do |code|
      get code, to: 'errors#not_found', code: code
    end
  end

  # SAML routes
  devise_scope :spree_user do
    get '/saml/sign_in' => 'devise/saml_sessions#new'
    post 'saml/auth' => 'devise/saml_sessions#create'
    match 'saml/signout' => 'devise/saml_sessions#destroy', via: %i[get post delete]
    get 'saml/metadata' => 'devise/saml_sessions#metadata'
    match 'saml/idp_sign_out' => 'devise/saml_sessions#idp_sign_out', via: %i[get post]
  end

end

# Override from: devise_saml_authenticable
ActionDispatch::Routing::Mapper.class_eval do
  protected

  def devise_saml_authenticatable(mapping, controllers)
    # Override the routes from gem and custom defined due to spree compatiability
  end
end
