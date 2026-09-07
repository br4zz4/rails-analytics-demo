Rails.application.routes.draw do
  mount RailsAnalytics::Engine => "/analytics"

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
  get "blog" => "pages#blog"
  get "blog/:slug" => "pages#post", as: :post
  get "produtos" => "pages#produtos"
  get "contato" => "pages#contato"
end