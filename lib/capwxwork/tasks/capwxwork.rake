namespace :wxwork do
  def post_to_wxwork(message, full_format: false)
    require 'net/http'
    require 'openssl'
    require 'json'

    stage = fetch(:stage)
    branch = fetch(:branch)
    app_name = fetch(:application)
    wxwork_config = fetch(:wxwork_config)

    uri = URI(wxwork_config[:web_hook])
    payload = {
      msgtype: 'markdown',
      markdown:
        {
          content: <<-MARKDOWN
    <font color="info">#{message}</font>
    >App Name: <font color="warning">#{app_name}</font>
    >Environment: <font color="warning">#{stage}</font>
    >Branch: <font color="warning">#{branch}</font>
          MARKDOWN
        }
    }
    # message_with_app_name = "*[#{wxwork_config[:app_name]}]*: #{message}"
    #
    # if full_format
    #   payload[:fallback] = "#{message_with_app_name}. (branch *#{branch}* on *#{stage}*)"
    #   payload[:color] = 'good'
    #   payload[:pretext] = message_with_app_name
    #   payload[:fields] = [
    #     {title: 'App Name', value: wxwork_config[:app_name], short: true},
    #     {title: 'Branch', value: branch, short: true},
    #     {title: 'Environment', value: stage, short: true},
    #     {title: 'Time At', value: Time.now.to_s, short: true}
    #   ]
    # else
    #   payload[:text] = "#{message_with_app_name}. (branch *#{branch}* on *#{stage}*)"
    # end
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Post.new uri.request_uri
      request.add_field('Content-Type', 'application/json')
      request.add_field('Accept', 'application/json')
      request.body = JSON.generate payload
      http.request request
    end
  end

  desc 'Send message to wxwork'
  task :notify, [:message, :full_format] do |_t, args|
    message = args[:message]
    full_format = args[:full_format]

    run_locally do
      with rails_env: fetch(:rails_env) do
        post_to_wxwork message, full_format: full_format
      end
    end

    Rake::Task['wxwork:notify'].reenable
  end
end
