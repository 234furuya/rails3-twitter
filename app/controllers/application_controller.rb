class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  def self.consumer
    OAuth::Consumer.new(
      'cufeNSXXynzlsq8fdftI5Q',
      't6tE81eVBcX5WwG8FQfgASxiMb3LF0pAGdX3tQJQcZc',
      {site: "http://api.twitter.com"}
    )
  end
end
