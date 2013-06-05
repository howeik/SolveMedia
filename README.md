# SolveMedia

Solve Media's patent-pending technology turns CAPTCHA into branded 
TYPE-IN&trade; Ads. Solve Media's technology improves site security, and every 
time a user types a brand message into a TYPE-IN&trade; Ad, we share the 
revenue with our publisher partners.

The Solve Media gem makes it easy to use the Solve Media unit in your Ruby and
Rails projects.

## Note

This gem supercedes and replaces the earlier gem from Solve Media, called
`solvemedia`. This new gem provides improved compatibility with Rails 3 and
is now also usable in pure Ruby as well. If you previously used the old gem with
Rails 3, you should uninstall it, install this one, and configure the keys as
below. Your view and controller code should continue to work without alteration.

This gem is not directly backward compatible with Rails 2. Rails 2 users should 
continue to use the old gem.

## Installation

Add this line to your application's Gemfile:

    gem 'solve_media'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install solve_media

## Usage

### Setting API Keys
Before using Solve Media, you need to 
[sign up for an account](https://portal.solvemedia.com/portal/public/signup) 
and get a set of API keys. 

To use within a Rails 3 project, you must set these keys within the app config.
Inside config/application.rb:

    config.solve_media.ckey = "Your Challenge (Public) Key"
    config.solve_media.vkey = "Your Verification (Private) Key"
    config.solve_media.hkey = "Your Authentication Hash Key"

In addition, you can set these keys on a per-environment basis by using the
environment configuration files under config/environment/. For instance, you
may wish to create a second set of keys with the security mode 
set to "Security" instead of "Revenue", to avoid receiving ads during 
development.

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
