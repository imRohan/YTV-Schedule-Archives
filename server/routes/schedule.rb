class Routes::Schedule < Bridgetown::Rack::Routes
  route do |r|
    r.on "api" do 
      r.get "schedule", String do |name|
        { hello: "friend #{name}" }
      end
    end
  end
end
