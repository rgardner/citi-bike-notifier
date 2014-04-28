# Name: exceptions.rb
# Description: Exceptions module for issues with citibikenyc.com
# Author: Bob Gardner
# Updated: 4/28/14
# License: MIT

# Excpetions module for citibikenyc.com website issues
module Exceptions
  # General problem with citibikenyc.com. e.x. HTTP 503 - GatewayTimeOut
  class CitiBikeWebsiteError < StandardError; end

  # Invalid login credentials
  class LoginError < CitiBikeWebsiteError; end
end

