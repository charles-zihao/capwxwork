namespace :wxwork do
  def post_to_wxwork(message, full_format: false)
    require 'net/http'
    require 'openssl'
    require 'json'

    stage = fetch(:stage)
    branch = fetch(:branch)
    app_name = fetch(:application)
    wxwork_config = fetch(:wxwork_config)
    time = Time.now.to_s
    uri = URI(wxwork_config[:web_hook])
    content = <<-MARKDOWN
    <font color="comment">#{message}</font>
    >App Name: <font color="info">#{app_name}</font>
    >Environment: <font color="info">#{stage}</font>
    >Branch: <font color="info">#{branch}</font>
    >Time At: <font color="info">#{time}</font>
    MARKDOWN
    payload = {
      'msgtype' => 'markdown',
      'markdown' =>
        {
          'content' => content.strip
        }
    }

    # Net::HTTP.post(uri, JSON.generate(payload), "Content-Type" => "application/json")

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
