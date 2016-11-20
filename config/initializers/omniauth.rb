OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '903261469804206', 'b061084bf2f142bd512d6f5c20ebf859'
end 
