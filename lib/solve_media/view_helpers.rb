module SolveMedia
    module ViewHelpers
        # View helper to insert the Solve Media puzzle HTML.
        #
        # * *Args*  :
        #   - +options+ -> Options hash
        # * *Options*   :
        #   - +:tabindex+::  HTML tabindex
        #   - +:theme+::
        #   - +:lang+::
        #   - +:size+::
        #       For +theme+, +lang+, and +size+, please see here: https://portal.solvemedia.com/portal/help/pub/themewiz
        #   - +:use_SSL+:: set to +true+ if using the puzzle on an HTTPS site
        #   - +:ajax+:: uses the AJAX api (https://portal.solvemedia.com/portal/help/pub/ajax)
        # * *Returns*   :
        #   - A string containing the HTML for the puzzle, marked as +html_safe+.
        def solvemedia_puzzle(options={})
            return SolveMedia.puzzle(CKEY, options).html_safe
        end
    end
end
