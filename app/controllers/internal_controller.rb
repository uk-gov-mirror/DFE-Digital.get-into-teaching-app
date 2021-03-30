class InternalController < ApplicationController
  before_action :authenticate
  helper_method :publisher?

protected

  def publisher?
    session[:publisher]
  end

private

  def set_account_role(role)
    session[role] = true
  end

  def authenticate
    authenticated = true
    authenticate_or_request_with_http_basic do |username, password|
      if username == "publisher" && password == "password"
        set_account_role(:publisher)
      elsif username == "author" && password == "password"
        set_account_role(:author)
      else
        authenticated = false
      end
      authenticated
    end
  end
end
