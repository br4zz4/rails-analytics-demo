class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # Demo pública: dashboard aberto. Em produção, usar Devise/CanCanCan.
  def authenticate_admin!
    true
  end
end
