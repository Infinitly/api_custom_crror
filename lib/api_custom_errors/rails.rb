module ApiCustomErrors
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller_api) do
      include ApiCustomErrors::Concern
    end

    initializer 'api_custom_errors.insert_middleware' do
      Rails.application.middleware.insert_after ActionDispatch::ShowExceptions, ApiCustomErrors::ShowExceptions
    end
  end
end
