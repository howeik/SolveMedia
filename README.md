# SolveMedia

Solve Media's patent-pending technology turns CAPTCHA into branded 
TYPE-IN&trade; Ads. Solve Media's technology improves site security, and every 
time a user types a brand message into a TYPE-IN&trade; Ad, we share the 
revenue with our publisher partners.

The Solve Media gem makes it easy to use the Solve Media unit in your Ruby and
Rails projects.

## Backward Compatibility 

This new gem provides improved compatibility with Rails 3 and is now also 
usable in pure Ruby as well. If you used a previous version of the Solve Media
gem, your keys were stored in `config/solvemedia_config.yml`. Keys are now
configured with the rest of your application config, in `config/application.rb`,
or in one of the environment config files. Since we recommend keeping your API 
keys in a separate file outside of version control, you may wish to keep 
`solvemedia_config.yml`. See "Setting API Keys" below.

*This gem is not directly backward compatible with Rails 2.* Rails 2 users should 
continue to use the old gem.

## Installation

Add this line to your application's Gemfile:

    gem 'solvemedia'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install solvemedia

## Usage

### Setting API Keys
Before using Solve Media, you need to 
[sign up for an account](https://portal.solvemedia.com/portal/public/signup) 
and get a set of API keys. 

To use within a Rails 3 project, you must set these keys within the app config.
Inside config/application.rb:

    config.solvemedia.ckey = "Your Challenge (Public) Key"
    config.solvemedia.vkey = "Your Verification (Private) Key"
    config.solvemedia.hkey = "Your Authentication Hash Key"

In addition, you can set these keys on a per-environment basis by using the
environment configuration files under config/environment/. For instance, you
may wish to create a second set of keys with the security mode 
set to "Security" instead of "Revenue", to avoid receiving ads during 
development.

These API keys should remain private and not be checked into version control, 
so we recommend storing them in a separate YAML or Ruby file. There are a number
of resources on the web dealing with configuration for Rails project, and we
encourage you to use a solution appropriate to your project.

### Displaying the Puzzle

To display the Solve Media puzzle within one of your form views, simply call
{SolveMedia::ViewHelpers#solvemedia_puzzle solvemedia_puzzle}.

    <% form_for(@user) do |f| %>
        #...
        <p>
            <%= solvemedia_puzzle %>
        </p>
        #...
    <% end %>

### Verifying the Response

The {SolveMedia::ControllerMethods#verify_solvemedia_puzzle verify_solvemedia_puzzle} method verifies the user's input, returning
`true` if the user solved the puzzle correctly.

    respond_to do |format|
        if verify_solvemedia_puzzle && @user.save
            #...
        else
            #...
        end
    end

`verify_solvemedia_puzzle` can also be used to add an error to a model object
if the verification fails:

    respond_to do |format|
        if verify_solvemedia_puzzle(:model => @user, :error_message => 'Solve Media puzzle input is invalid') && @user.save
            #...
        else
            #...
        end
    end
