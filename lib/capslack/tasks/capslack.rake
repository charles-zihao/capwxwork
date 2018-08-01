namespace :capslack do

  def post_to_slack message, full_format: false
    require 'net/http'
    require 'openssl'
    require 'json'

    stage = fetch(:stage)
    branch = fetch(:branch)
    slack_config = fetch(:slack_config)

    uri = URI(slack_config[:web_hook])
    payload = {
      channel: slack_config[:channel],
      icon_emoji: ':rocket:',
      username: 'Capistrano',
      pretty: 1
    }

    message_with_app_name = "*[#{slack_config[:app_name]}]*: #{message}"

    if full_format
      payload[:fallback] = "#{message_with_app_name}. (branch *#{branch}* on *#{stage}*)"
      payload[:color] = 'good'
      payload[:pretext] = message_with_app_name
      payload[:fields] = [
        {title: 'App Name', value: slack_config[:app_name], short: true},
        {title: 'Branch', value: branch, short: true},
        {title: 'Environment', value: stage, short: true},
        {title: 'Time At', value: Time.now.to_s, short: true}
      ]
    else
      payload[:text] = "#{message_with_app_name}. (branch *#{branch}* on *#{stage}*)"
    end

    Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Post.new uri.request_uri
      request.add_field('Content-Type', 'application/json')
      request.add_field('Accept', 'application/json')
      request.body = payload.to_json
      http.request request
    end
  end

  desc 'Send message to slack chennel'
  task :notify, [:message, :full_format] do |_t, args|
    message = args[:message]
    full_format = args[:full_format]

    run_locally do
      with rails_env: fetch(:rails_env) do
        post_to_slack message, full_format: full_format
      end
    end

    Rake::Task['slack:notify'].reenable
  end

end
