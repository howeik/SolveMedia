require "solve_media/version"
require "solve_media/constants"
require "solve_media/ad_copy_error"
require "solve_media/railtie" if defined? ::Rails::Railtie
require 'net/http'
require 'timeout'

module SolveMedia

  # Returns the HTML for the Solve Media puzzle.
  #
  # * *Args*    :
  #   - +ckey+ -> your challenge key
  #   - +options+ -> options hash (see below)
  # * *Options* :  
  #   - +:tabindex+::  HTML tabindex
  #   - +:theme+::
  #   - +:lang+::
  #   - +:size+::
  #       For +theme+, +lang+, and +size+, please see here: https://portal.solvemedia.com/portal/help/pub/themewiz
  #   - +:use_SSL+:: set to +true+ if using the puzzle on an HTTPS site
  #   - +:ajax+:: uses the AJAX api (https://portal.solvemedia.com/portal/help/pub/ajax)
  # * *Returns*   :
  #   - HTML string containing code to display the puzzle
  # * *Raises*    :
  #   - +AdCopyError+ -> if the ckey is missing
  def self.puzzle(ckey, options = {})
      raise AdCopyError, "Solve Media API keys not found. Keys can be obtained at #{SIGNUP_URL}" unless ckey

      options = { :tabindex => nil,
                  :theme    => 'purple',
                  :lang     => 'en',
                  :size     => '300x150',
                  :use_SSL  => false
                  :ajax     => false
                }.merge(options)
      
      server = options[:use_SSL] ? SolveMedia::API_SECURE_SERVER : SolveMedia::API_SERVER
      
      if options[:ajax]
        aopts = {:theme => options[:theme], :lang => options[:lang], :size => options[:size]}
        aopts[:tabindex] = options[:tabindex] if options[:tabindex]

        output = <<-EOF
          <script src="#{server}/papi/challenge.ajax" />
          <script>
            function loadSolveMediaCaptcha(){
              if(window.ACPuzzle) { 
                  ACPuzzle.create('#{ckey}', '#{options[:ajax_div]}', {#{aopts.map{|k,v| "#{k}:'#{v}'" }.join(', ') }});
              } else {
                  setTimeout(loadSolveMediaCaptcha, 50);
              }
            }
            loadSolveMediaCaptcha();
          </script>
        EOF
      else
        output = []
        
        output << %{<script type="text/javascript">}
        output << "	var ACPuzzleOptions = {"
        output << %{			tabindex:   #{options[:tabindex]},} unless options[:tabindex].nil?
        output << %{			theme:      '#{options[:theme]}',}
        output << %{			lang:       '#{options[:lang]}',}
        output << %{			size:       '#{options[:size]}'}
        output << "	};"
        output << %{</script>}
        
        output << %{<script type="text/javascript"}
        output << %{   src="#{server}/papi/challenge.script?k=#{ckey}">}
        output << %{</script>}

        output << %{<noscript>}
        output << %{   <iframe src="#{server}/papi/challenge.noscript?k=#{ckey}"}
        output << %{	 height="300" width="500" frameborder="0"></iframe><br/>}
        output << %{   <textarea name="adcopy_challenge" rows="3" cols="40">}
        output << %{   </textarea>}
        output << %{   <input type="hidden" name="adcopy_response"}
        output << %{	 value="manual_challenge"/>}
        output << %{</noscript>}
        output = output.join("\n")
      end
      return output
  end

  # Sends a POST request to the Solve Media server in order to verify the user's input.
  #
  # * *Args*    :
  #   - +challenge+ -> The challenge id. Normally found in the form field +adcopy_challenge+
  #   - +acresponse+ -> The user's response to the puzzle. Normally found in the form field +adcopy_response+
  #   - +vkey+ -> Your verification key
  #   - +hkey+ -> Your hash key
  #   - +remote_ip+ -> The IP from which the form was submitted
  #   - +options+ -> Options hash (see below)
  # * *Options* :  
  #   - +:validate_response+::  Whether or not the Solve Media authenticator should be used to validate the server's response. Defaults to +true+
  #   - +:timeout+:: The amount of time in seconds before the request should timeout
  # * *Returns*   :
  #   - +true+ or +false+, depending on whether the user's answer was correct
  # * *Raises*    :
  #   - +AdCopyError+ -> If +validate_response+ is true and the response cannot be verified
  #   - +Timeout::Error+ -> If the request to the verification server takes longer than the specified time
  def self.verify(challenge, acresponse, vkey, hkey, remote_ip, options = {})
    options = { :validate_response  => true,
                :timeout            => 5,
              }.merge(options)
    
    #Send POST to SolveMedia
    response = nil
    Timeout::timeout(options[:timeout]) do
      response = Net::HTTP.post_form URI.parse("#{SolveMedia::VERIFY_SERVER}/papi/verify"), {
        "privatekey"  =>  vkey,  
        "challenge"   =>  challenge,
        "response"    =>  acresponse,
        "remoteip"    =>  remote_ip
      }
    end

    answer, error, authenticator = response.body.split("\n")

    #validate the response
    if options[:validate_response] && authenticator != Digest::SHA1.hexdigest("#{answer}#{challenge}#{hkey}")
      raise AdCopyError, "SolveMedia Error: Unable to Validate Response" 
    end
    
    return answer.downcase == "true" ? true : false
  end
end
