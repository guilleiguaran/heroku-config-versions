module SharedConfigBackup
  def update_config_backup
    vars = api.get_config_vars(app).body
    _, versions_data = vars.detect {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

    if versions_data
      versions = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(versions_data)))
    else
      versions = {}
    end

    time = Time.now.utc.strftime("%Y%m%d%H%M%S")
    versions[time] = vars.reject {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

    encoded_versions = Base64.encode64(Zlib::Deflate.deflate(JSON.generate(versions)))
    api.put_config_vars(app, {'HEROKU_CONFIG_VERSIONS' => encoded_versions})
  end  
end
