case Rails.env
when 'development'
  FederalRegister::Base.override_base_uri Settings.federal_register.api_url
when 'test'
  #FederalRegister::Base.override_base_uri 'http://127.0.0.1:8081/api/v1'
when 'staging'
  FederalRegister::Base.override_base_uri 'https://fr2.criticaljuncture.org/api/v1'
when 'officialness_staging'
  FederalRegister::Base.override_base_uri 'https://fr-official.criticaljuncture.org/api/v1'
when 'production'
end

