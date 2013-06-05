require "solvemedia/view_helpers"
require "solvemedia/controller_methods"
module SolveMedia
  # Integrates the Solve Media library into the Rails project.
  # Adds {SolveMedia::ViewHelpers} and {SolveMedia::ControllerMethods} to
  # to the project.
  class Railtie < Rails::Railtie
    config.solvemedia = ActiveSupport::OrderedOptions.new

    initializer "solvemedia.configure" do |app|
      SolveMedia::CKEY = app.config.solvemedia[:ckey] 
      SolveMedia::VKEY = app.config.solvemedia[:vkey]
      SolveMedia::HKEY = app.config.solvemedia[:hkey]

      unless (SolveMedia::CKEY && SolveMedia::VKEY && SolveMedia::HKEY)
        raise AdCopyError, "Solve Media API keys not found. Keys can be obtained at #{SIGNUP_URL}"
      end
    end
    
    initializer "solvemedia.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end

    initializer "solvemedia.controller_methods" do
      ActionController::Base.send :include, ControllerMethods
    end
  end
end
