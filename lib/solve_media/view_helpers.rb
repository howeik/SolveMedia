module SolveMedia
    module ViewHelpers
      # View helper to insert the Solve Media puzzle HTML.
      # Calls {SolveMedia.puzzle} internally.
      #
      # @param [Hash] options
      #
      # @option options [Integer] :tabindex (nil) HTML tabindex
      # @option options [String] :theme ('purple')
      # @option options [String] :lang ('en')
      # @option options [String] :size ('300x150') Widget size. Please note that
      #   300x150 is the only size which can display ads.
      # @option options [Boolean] :use_SSL (false) Set to +true+ if using the puzzle
      #   on an HTTPS site
      # @option options [Boolean] :ajax (false) Uses the AJAX api
      #   (https://portal.solvemedia.com/portal/help/pub/ajax)
      #
      # @return [String] HTML for the puzzle, marked as +html_safe+.
        def solvemedia_puzzle(options={})
            return SolveMedia.puzzle(CKEY, options).html_safe
        end
    end
end
