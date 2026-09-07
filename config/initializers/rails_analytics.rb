# frozen_string_literal: true

RailsAnalytics.configure do |config|
  # Demo app: sem Devise — usa um método simples de sessão.
  config.auth_callback = :authenticate_admin!
  config.mount_path = "/analytics"
  config.since_default = 30.days
end
