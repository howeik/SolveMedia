module SolveMedia
  module ControllerMethods
    # Controller method to verify a Solve Media puzzle. Assumes a form with
    # the puzzle is being processed by the calling method. 
    # Calls {SolveMedia.verify} internally.
    #
    # @param [Hash] options
    # 
    # @option options [Boolean] :validate_response (true) Validate the 
    #   response from the Solve Media server
    # @option options [Integer] :timeout (5) Time in seconds to wait for a 
    #   response form the Solve Media server
    # @option options [Object<ActiveRecord::Base>] :model ActiveRecord model
    #   object to which error is added
    # @option options [String] :error_message Custom error message to add to
    #   the model. Does nothing if +:model+ is not present
    #
    # @raise [AdCopyError] if +validate_response+ is true and the response
    #   cannot be verified
    # @raise [Timeout::Error] if the request to the verification server takes
    #   longer than expected
    #
    # @return [Boolean] Was the user's answer correct?
    #
    def verify_solvemedia_puzzle(options={})
      ver_options = { :validate_response => options[:validate_response] || true,
                      :timeout           => options[:timeout] || 5
      }
      verified = SolveMedia.verify(params[:adcopy_challenge], params[:adcopy_response], VKEY, HKEY, request.remote_ip)
      if options[:model] && !verified
        options[:model].valid?
        options[:model].errors.add(:base, options[:error_message] || "Please fill out the Solve Media puzzle")
      end

      return verified
    end
  end
end
