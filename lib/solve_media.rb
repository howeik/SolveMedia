require "solve_media/version"
require "solve_media/constants"
require "solve_media/ad_copy_error"
require "solve_media/railtie" if defined? ::Rails::Railtie

module SolveMedia
  def self.puzzle(ckey, options = {})
      raise AdCopyError, "Solve Media API keys not found. Keys can be obtained at #{SIGNUP_URL}" unless ckey

      options = { :tabindex => nil,
                  :theme    => 'purple',
                  :lang     => 'en',
                  :size     => '300x150',
                  :use_SSL  => false
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
  # Returns +true+ if the user's input is valid, +false+ otherwise
  #
  # Options:
  # <tt>:validate_response</tt>::  Whether or not the Solve Media authenticator should be used to validate the server's response. If this is set to +true+ and the validation fails, an AdCopyError is raised.
  # <tt>:timeout</tt>::  The amount of time in seconds before the request should timeout. If the request times out, a Timeout::Error is raised.
  # <tt>:model</tt>::  An ActiveRecord model. If verification fails, an error will be added to this model.
  # <tt>:error_message</tt>::  A custom error message (to be used in conjunction with <tt>:model</tt>) to be used if verification fails.
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
