require "solve_media/view_helpers"
require "solve_media/controller_methods"
module SolveMedia
    # Integrates the Solve Media library into the Rails project.
    # Adds {SolveMedia::ViewHelpers} and {SolveMedia::ControllerMethods} to
    # to the project.
    class Railtie < Rails::Railtie
        config.solve_media = ActiveSupport::OrderedOptions.new

        initializer "solve_media.configure" do |app|
            SolveMedia::CKEY = app.config.solve_media[:ckey] 
            SolveMedia::VKEY = app.config.solve_media[:vkey]
            SolveMedia::HKEY = app.config.solve_media[:hkey]

            unless (SolveMedia::CKEY && SolveMedia::VKEY && SolveMedia::HKEY)
                raise AdCopyError, "Solve Media API keys not found. Keys can be obtained at #{SIGNUP_URL}"
            end
        end
        
        initializer "solve_media.view_helpers" do
            ActionView::Base.send :include, ViewHelpers
        end

        initializer "solve_media.controller_methods" do
            ActionController::Base.send :include, ControllerMethods
        end
    end
end
