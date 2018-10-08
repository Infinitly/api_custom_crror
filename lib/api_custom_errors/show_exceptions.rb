module ApiCustomErrors
  class ShowExceptions
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue ActionController::RoutingError => exception
      request = ActionDispatch::Request.new(env)

      raise exception unless request.show_exceptions?

      response = ActionDispatch::Response.new.tap do |res|
        res.request = request
      end

      ApplicationController.dispatch(:route_not_found, request, response)
    end
  end
end
