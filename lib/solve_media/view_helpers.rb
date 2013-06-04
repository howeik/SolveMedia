module SolveMedia
  module ViewHelpers
    # View helper to insert the Solve Media puzzle HTML.
    #
    # Can be set to use either the standard version or the AJAX version. For 
    # more complex uses of the AJAX version, such as multi-puzzle, you should 
    # not use this method and instead use purpose-written Javascript in your 
    # view.
    #
    # Calls {SolveMedia.puzzle} internally.
    # 
    # @see https://portal.solvemedia.com/portal/help/pub/themewiz
    #   Documentation for theme, lang, and size
    # @see https://portal.solvemedia.com/portal/help/pub/ajax
    #   AJAX API documentation
    # @see SolveMedia.puzzle
    #
    #
    # @param [Hash] options
    # @option (see SolveMedia.puzzle)
    #
    # @raise (see SolveMedia.puzzle)
    #
    # @return [String] HTML for the puzzle, marked as +html_safe+.
    def solvemedia_puzzle(options={})
      return SolveMedia.puzzle(CKEY, options).html_safe
    end
  end
end
