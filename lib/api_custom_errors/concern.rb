module ApiCustomErrors
  module Concern
    extend ActiveSupport::Concern

    included do
      rescue_from Exception, with: :internal_server_error
      rescue_from Pundit::NotAuthorizedError, with: :forbidden if defined?(Pundit)
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    end

    def route_not_found(exception = nil)
      response = if block_given?
        yield exception
      else
        { status: 404, error: 'route not found' }
      end

      render json: response, status: :not_found
    end

    def internal_server_error(exception = nil)
      # Based on /actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L76 [~> v5.0.0, <= v5.2.1]
      backtrace_cleaner = respond_to?(:request) && request.get_header('action_dispatch.backtrace_cleaner')
      wrapper = backtrace_cleaner && exception && ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, exception)

      log_error(wrapper) if wrapper

      response = if block_given?
        yield wrapper
      else
        extra = {}

        # Based on /actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L108 [~> v5.0.0, <= v5.2.1]
        if wrapper && Rails.env.development?
          extra[:exception] = wrapper.exception.inspect
          extra[:traces] = wrapper.traces
        end

        { status: 500, error: 'internal server error' }.merge(extra)
      end

      render json: response, status: :internal_server_error
    end

    protected

    def forbidden(exception)
      response = if block_given?
        yield exception
      else
        { status: 403, error: 'forbidden' }
      end

      render json: response, status: :forbidden
    end

    def parameter_missing(exception)
      response = if block_given?
        yield exception
      else
        { status: 400, error: exception }
      end

      render json: response, status: :bad_request
    end

    def record_not_found(exception)
      response = if block_given?
        yield exception
      else
        { status: 404, error: 'record not found' }
      end

      render json: response, status: :not_found
    end

    # Based on /actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L161 [~> v5.0.0, <= v5.2.1]
    def log_error(wrapper)
      exception = wrapper.exception

      trace = wrapper.application_trace
      trace = wrapper.framework_trace if trace.empty?

      ActiveSupport::Deprecation.silence do
        message = "  \n"
        message << "#{exception.class} (#{exception.message}):\n"
        message << "#{log_array(exception.annoted_source_code)}\n" if exception.respond_to?(:annoted_source_code)
        message << "  \n"
        message << "#{log_array(trace)}\n"
        message << '  '

        Rails.logger.error message
      end
    end

    # Based on /actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L179 [~> v5.0.0, <= v5.2.1]
    def log_array(array)
      if Rails.logger.formatter.respond_to?(:tags_text)
        array.join("\n#{Rails.logger.formatter.tags_text}")
      else
        array.join("\n")
      end
    end
  end
end
