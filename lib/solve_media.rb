require "solve_media/version"
require "solve_media/constants"
require "solve_media/ad_copy_error"
require "solve_media/railtie" if defined? ::Rails::Railtie
require 'net/http'
require 'timeout'

# Methods for using the Solve Media service. These methods are called internally
# by the Rails Railtie; those not using Rails may call these methods directly.
module SolveMedia

  # Returns the HTML for the Solve Media puzzle.
  # For theme, lang, and size options, see 
  # (https://portal.solvemedia.com/portal/help/pub/themewiz)
  #
  # @param [String] ckey Your challenge (public) key
  # @param [Hash] options
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
  # @raise [AdCopyError] if key is not set
  #
  # @return [String] HTML string containing code to display the puzzle
  #
  def self.puzzle(ckey, options = {})
      raise AdCopyError, "Solve Media API keys not found. Keys can be obtained at #{SIGNUP_URL}" unless ckey

      options = { :tabindex => nil,
                  :theme    => 'purple',
                  :lang     => 'en',
                  :size     => '300x150',
                  :use_SSL  => false,
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
  # @param [String] challenge The challenge id. Normally found in the form
  #   field +adcopy_challenge+
  # @param [String] response The user's response to the puzzle. Normally found
  #   in the form field +acdopy_response+
  # @param [String] vkey Your verification (private) key
  # @param [String] hkey Your hash key
  # @param [String] remote_ip The IP from which the form was submitted
  # @param [Hash] options
  #
  # @option options [Boolean] :validate_response (true) Validate the response
  #   from the Solve Media server
  # @option options [Integer] :timeout (5) Amount of time in seconds before the
  #   request should time out
  #
  # @return [Boolean] Was the user's answer correct?
  #
  # @raise [AdCopyError] if +validate_response+ is true and the response
  #   cannot be verified
  # @raise [Timeout::Error] if the request to the verification server takes
  #   longer than expected
  #
  def self.verify(challenge, response, vkey, hkey, remote_ip, options = {})
    options = { :validate_response  => true,
                :timeout            => 5,
              }.merge(options)
    
    #Send POST to SolveMedia
    result = nil
    Timeout::timeout(options[:timeout]) do
      result = Net::HTTP.post_form URI.parse("#{SolveMedia::VERIFY_SERVER}/papi/verify"), {
        "privatekey"  =>  vkey,  
        "challenge"   =>  challenge,
        "response"    =>  response,
        "remoteip"    =>  remote_ip
      }
    end

    answer, error, authenticator = result.body.split("\n")

    #validate the response
    if options[:validate_response] && authenticator != Digest::SHA1.hexdigest("#{answer}#{challenge}#{hkey}")
      raise AdCopyError, "SolveMedia Error: Unable to Validate Response" 
    end
    
    return answer.downcase == "true" ? true : false
  end
end
