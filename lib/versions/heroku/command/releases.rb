require "heroku/command/releases"

module ReleasesExtensions
  include SharedConfigBackup

  # releases:rollback [RELEASE] [CONFIG]
  #
  # roll back to an older release
  #
  # if RELEASE is not specified, will roll back one step
  #
  #Example:
  #
  # $ heroku releases:rollback
  # Rolling back example... done, v122
  #
  # $ heroku releases:rollback v42
  # Rolling back example to v42... done
  #
  def rollback
    release = shift_argument

    action("Rolling back #{app}") do
      status(api.post_release(app, release).body)
    end

    if version = shift_argument
      vars = api.get_config_vars(app).body
      _, versions_data = vars.detect {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

      if versions_data
        versions = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(versions_data)))

        if version_vars = versions[version]
          version_vars.reject! {|k,v| k =~ /HEROKU_POSTGRES/}
          action("Rolling back #{app} config vars to version #{version}") do
            status(api.put_config_vars(app, version_vars))
          end
          update_config_backup
        else
          display("There are any version named #{version}")
        end
      else
        display("#{app} has no versioned config vars.")
      end
    end
  end
end

class Heroku::Command::Releases
  prepend ReleasesExtensions
end
