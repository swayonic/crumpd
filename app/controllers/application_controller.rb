class ApplicationController < ActionController::Base
  protect_from_forgery

  if Rails.env.production?
    def default_url_options(options = {})
      { :only_path => false, :protocol => 'https' }
    end
  end

end
