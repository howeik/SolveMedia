module SolveMedia
    module ControllerMethods
        # Controller method to verify a Solve Media puzzle. Assumes a form with
        # the puzzle is being processed by the calling method.
        #
        # * *Args*  :
        #   - +options+ -> Options hash
        # * *Options*   :
        #   - +:validate_response+:: Validate the response from the Solve Media server. Defaults to +true+
        #   - +:timeout+:: Time in seconds to wait for a response from the Solve Media server. Defaults to 5
        #   - +:model+:: A model object to add errors to
        #   - +:error_message+:: Custom error message to add to the model
        # * *Returns*   :
        #   - +true+ or +false+, based on whether the answer was correct or not
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
