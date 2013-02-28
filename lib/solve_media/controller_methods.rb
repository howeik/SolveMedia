module SolveMedia
    module ControllerMethods
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
