module SolveMedia
    module ControllerMethods
        require 'net/http'
        require 'timeout'

        def verify_solvemedia_puzzle(options={})
            return SolveMedia.verify(params[:adcopy_challenge], params[:adcopy_response], VKEY, HKEY, request.remote_ip)
        end
    end
end
