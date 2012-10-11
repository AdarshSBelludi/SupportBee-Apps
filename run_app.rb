require 'sinatra/base'
require 'sinatra-initializers'

class RunApp < Sinatra::Base
  
  register Sinatra::Initializers

  def self.setup(app_class)
    get "/#{app_class.slug}" do
      config = app_class.configuration
      response = {:name => config['name'], :slug => config['slug'], :description => config['description']}
      content_type :json
      {app_class.slug => response}.to_json
    end

    get "/#{app_class.slug}/schema" do
      response = app_class.schema
      content_type :json
      {app_class.slug => response}.to_json
    end

    get "/#{app_class.slug}/config" do
      response = app_class.configuration
      content_type :json
      {app_class.slug => response}.to_json
    end

    post "/#{app_class.slug}/event/:event" do
      event, data, payload = parse_request
      if app = app_class.trigger_event(event, data, payload)
        "OK"
      end
    end

    post "/#{app_class.slug}/action/:action" do
      event, data, payload = parse_request
      if app = app_class.trigger_action(action, data, payload)
        "OK"
      end
    end
  end

  SupportBeeApp::Base.apps.each do |app|
    app.setup_for(self)
  end

  get "/" do
    "OK"
  end

  def parse_request
    parse_json_request
  end

  def parse_json_request
    req = JSON.parse(request.body.read)
    [params[:event], req['data'], req['payload']]
  end

  run! if app_file == $0
end
