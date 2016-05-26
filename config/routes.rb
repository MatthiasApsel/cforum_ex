# -*- coding: utf-8 -*-

Cforum::Application.routes.draw do
  devise_for(:users, path_names: {sign_in: 'login',
                                  sign_out: 'logout'},
             skip: :registration,
             controllers: {confirmations: "users/confirmations"})

  devise_scope :user do
    get '/users/registration/cancel' => 'users/registrations#cancel',
        as: :cancel_user_registration
    post '/users/registration' => 'users/registrations#create',
         as: :user_registration
    get '/users/registration' => 'users/registrations#new',
        as: :new_user_registration
  end

  get '/m:id' => 'forums#message_redirect', id: /\d+/

  get "/search" => "search#show", as: :search
  post "/search" => "search#show"

  get 'cites/old/:id' => 'cites#redirect'
  get 'cites/voting' => 'cites#vote_index', as: :cites_vote
  post 'cites/:id/vote' => 'cites#vote', as: :cite_vote
  resources 'cites'

  get "/forums" => "forums#redirector", as: :forum_redirector
  get '/forums_titles' => "forums#title"

  # we use a custom url style for mails to achieve grouping
  get '/mails' => 'mails#index', as: :mails
  post '/mails' => 'mails#create'
  get '/mails/new' => 'mails#new', as: :new_mail
  get '/mails/:user' => 'mails#index', as: :user_mails
  get '/mails/:user/:id' => 'mails#show', as: :mail
  delete '/mails/:user/:id' => 'mails#destroy'
  delete '/mails' => 'mails#batch_destroy'
  post '/mails/:user/:id' => 'mails#mark_read_unread'

  get '/badges' => 'badges#index', as: :badges
  get '/badges/:slug' => 'badges#show', as: :badge

  get '/users/:id/destroy' => 'users#confirm_destroy', as: :users_confirm_destroy
  get '/users/:id/scores' => 'users#show_scores', as: :user_scores
  get '/users/:id/votes' => 'users#show_votes', as: :user_votes
  get '/users/:id/messages' => 'users#show_messages', as: :user_messages
  resources :users, except: [:new, :create]

  resources :notifications, except: [:edit, :new, :create]
  delete 'notifications' => 'notifications#batch_destroy'

  post 'preview' => 'messages#preview'

  get 'help' => 'pages#help', as: :help

  namespace 'admin' do
    resources :users, except: :show
    resources :groups, controller: :groups, except: :show
    resources :forums, controller: :forums, except: :show
    resources :badges, except: :show
    resources :search_sections, except: :show
    resources :badge_groups, except: :show

    get 'settings' => 'settings#edit', as: 'settings'
    post 'settings' => 'settings#update'

    get '/forums/:id/merge' => 'forums#merge', as: 'forums_merge'
    post '/forums/:id/merge' => 'forums#do_merge', as: 'forums_do_merge'

    get '/audit' => 'audit#index'
    get '/audit/:id' => 'audit#show'

    get '/jobs' => 'jobs#index'

    root to: "users#index"
  end

  get '/all' => 'cf_threads#index'

  get '/interesting' => 'messages/interesting#list_interesting_messages',
      as: :interesting_messages
  get '/invisible' => 'cf_threads/invisible#list_invisible_threads',
      as: :hidden_threads

  get '/choose_css' => 'css_chooser#choose_css',
      as: :choose_css
  post '/choose_css' => 'css_chooser#css_chosen'

  resources 'images', except: [:new, :edit, :update]

  # old archive url
  get '/archiv' => 'forums#redirect_archive'
  get '/archiv/:year' => 'forums#redirect_archive_year', year: /\d{4}/
  get '/archiv/:year/:mon' => 'forums#redirect_archive_mon', year: /\d{4}/, mon: /\d{1,2}/
  get '/archiv/:year/:mon/:tid' => 'forums#redirect_archive_thread', year: /\d{4}/, mon: /\d{1,2}/, tid: /t\d+/


  scope ":curr_forum" do
    get 'stats' => 'forums#stats'
    get 'tags/autocomplete' => 'tags#autocomplete'
    post 'tags/suggestions' => 'tags#suggestions'
    get 'tags/:id/merge' => 'tags#merge', as: :merge_tag
    post 'tags/:id/merge' => 'tags#do_merge'
    resources :tags do
      resources :synonyms, except: [:show, :index]
    end

    get '/redirect-to-page' => 'cf_threads#redirect_to_page'

    get '/' => 'cf_threads#index', as: 'cf_threads'

    post '/mark_all_visited' => 'messages/mark_read#mark_all_read',
         as: 'mark_all_read'

    post '/close_all' => 'cf_threads/open_close#close_all',
         as: 'close_all_threads'
    post '/open_all' => 'cf_threads/open_close#open_all',
         as: 'open_all_threads'

    get '/archive' => 'archive#years', as: :archive
    get '/:year' => 'archive#year', as: :archive_year, year: /\d{4}/
    get '/:year/:month' => 'archive#month', as: :archive_month, year: /\d{4}/, mon: /\w{3}/

    #
    # thread urls
    #
    post '/' => 'cf_threads#create'
    get '/new' => 'cf_threads#new', as: 'new_cf_thread'

    get '/:year/:mon/:day/:tid' => 'cf_threads#show', year: /\d{4}/,
        mon: /\w{3}/, day: /\d{1,2}/, as: 'show_cf_thread_feed'

    get '/:year/:mon/:day/:tid/move' => 'cf_threads#moving', year: /\d{4}/,
        mon: /\w{3}/, day: /\d{1,2}/, as: 'move_cf_thread'
    post '/:year/:mon/:day/:tid/move' => 'cf_threads#move', year: /\d{4}/,
         mon: /\w{3}/, day: /\d{1,2}/
    post '/:year/:mon/:day/:tid/sticky' => 'cf_threads#sticky', year: /\d{4}/,
         mon: /\w{3}/, day: /\d{1,2}/
    post '/:year/:mon/:day/:tid/no_archive' => 'cf_threads/no_answer_no_archive#no_archive',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'no_archive_cf_thread'
    post '/:year/:mon/:day/:tid/mark_read' => 'messages/mark_read#mark_thread_read', year: /\d{4}/,
         mon: /\w{3}/, day: /\d{1,2}/, as: :mark_thread_read

    post '/:year/:mon/:day/:tid/open' => 'cf_threads/open_close#open',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'open_cf_thread'
    post '/:year/:mon/:day/:tid/close' => 'cf_threads/open_close#close',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'close_cf_thread'

    post '/:year/:mon/:day/:tid/hide' => 'cf_threads/invisible#hide_thread',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'hide_cf_thread'
    post '/:year/:mon/:day/:tid/unhide' => 'cf_threads/invisible#unhide_thread',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: :unhide_cf_thread

    #
    # message urls
    #
    get '/:year/:mon/:day/:tid/:mid' => 'messages#show', year: /\d{4}/,
        mon: /\w{3}/, day: /\d{1,2}/, as: 'message'
    get '/:year/:mon/:day/:tid/:mid/edit' => 'messages#edit',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'edit_message'
    patch '/:year/:mon/:day/:tid/:mid/edit' => 'messages#update',
          year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/
    delete '/:year/:mon/:day/:tid/:mid' => 'messages#destroy',
           year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/
    get '/:year/:mon/:day/:tid/:mid/retag' => 'messages#show_retag',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'retag_message'
    post '/:year/:mon/:day/:tid/:mid/retag' => 'messages#retag',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/

    post '/:year/:mon/:day/:tid/:mid/vote' => 'messages/vote#vote',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'vote_message'

    post '/:year/:mon/:day/:tid/:mid/interesting' => 'messages/interesting#mark_interesting',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'interesting_message'
    post '/:year/:mon/:day/:tid/:mid/boring' => 'messages/interesting#mark_boring',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'boring_message'


    #
    # admin actions
    #
    post '/:year/:mon/:day/:tid/:mid/restore' => 'messages#restore',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'restore_message'
    post '/:year/:mon/:day/:tid/:mid/no_answer' => 'cf_threads/no_answer_no_archive#no_answer',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'no_answer_message'

    #
    # Plugins
    #
    post '/:year/:mon/:day/:tid/:mid/accept' => 'messages/accept#accept',
         year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'accept_message'

    get '/:year/:mon/:day/:tid/:mid/close' => 'close_vote#new',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'close_message'
    put '/:year/:mon/:day/:tid/:mid/close' => 'close_vote#create',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/
    patch '/:year/:mon/:day/:tid/:mid/close' => 'close_vote#vote',
          year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/

    get '/:year/:mon/:day/:tid/:mid/open' => 'close_vote#new_open',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'open_message'
    put '/:year/:mon/:day/:tid/:mid/open' => 'close_vote#create_open',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/
    patch '/:year/:mon/:day/:tid/:mid/open' => 'close_vote#vote_open',
          year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/


    get '/:year/:mon/:day/:tid/:mid/flag' => 'messages/flag#flag',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'flag_message'
    put '/:year/:mon/:day/:tid/:mid/flag' => 'messages/flag#flagging',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/
    delete '/:year/:mon/:day/:tid/:mid/unflag' => 'messages/flag#unflag',
           year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/

    get '/:year/:mon/:day/:tid/:mid/versions' => 'messages#versions',
        year: /\d{4}/, mon: /\w{3}/, day: /\d{1,2}/, as: 'message_versions'

    #
    # new and create messages
    #
    get '/:year/:mon/:day/:tid/:mid/new' => 'messages#new', year: /\d{4}/,
        mon: /\w{3}/, day: /\d{1,2}/, as: 'new_message'
    post '/:year/:mon/:day/:tid/:mid' => 'messages#create', year: /\d{4}/,
         mon: /\w{3}/, day: /\d{1,2}/
  end

  # show forum index in root
  root to: 'forums#index'
end

# eof
