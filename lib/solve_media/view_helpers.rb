module SolveMedia
    module ViewHelpers
        def solvemedia_puzzle(options={})
            return SolveMedia.puzzle(CKEY, options).html_safe
        end
    end
end
