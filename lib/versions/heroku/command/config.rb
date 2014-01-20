require "json"
require "zlib"
require "base64"
require "heroku/command/config"

module ConfigExtensions
  def index
    validate_arguments!

    vars = api.get_config_vars(app).body
    if vars.empty?
      display("#{app} has no config vars.")
    else
      vars.reject!{|k,v| k == 'HEROKU_CONFIG_VERSIONS'}
      vars.each {|key, value| vars[key] = value.to_s}
      if options[:shell]
        vars.keys.sort.each do |key|
          display(%{#{key}=#{vars[key]}})
        end
      else
        styled_header("#{app} Config Vars")
        styled_hash(vars)
      end
    end
  end

  def set
    update_config_backup
    super
  end

  def unset
    update_config_backup
    super
  end

  private

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


class Heroku::Command::Config
  prepend ConfigExtensions

  # config:versions
  #
  # display a list of all the config variable versions saved for an app
  #
  #Example:
  #
  # $ heroku config:versions
  # Saved config versions for example:
  # 20140118042745 (saved on 2014-01-18 04:27:45 -0500)
  # 20140118042753 (saved on 2014-01-18 04:27:53 -0500)
  # 20140118042801 (saved on 2014-01-18 04:28:01 -0500)
  #
  def versions
    vars = api.get_config_vars(app).body
    _, versions_data = vars.detect {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

    if versions_data
      versions = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(versions_data)))

      display("Saved config versions for #{app}: ")
      versions.keys.each do |version|
        time = Time.strptime(version, "%Y%m%d%H%M%S", Time.now.utc)
        display("#{version} (saved on #{time.to_s})")
      end
    else
      display("#{app} has no versioned config vars.")
    end
  end

  # config:version VERSION
  #
  # display the config variables information for a VERSION
  #
  #Example:
  #
  # $ heroku config:version 20140118042753
  # === example Config Vars for version 20140118042753
  # EXAMPLE: foo
  #
  def version
    unless version = shift_argument
      error("Usage: heroku config:version VERSION\nMust specify VERSION.")
    end

    vars = api.get_config_vars(app).body
    _, versions_data = vars.detect {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

    if versions_data
      versions = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(versions_data)))

      if version_vars = versions[version]
        styled_header("#{app} Config Vars for version #{version}")
        styled_hash(version_vars)
      else
        display("There are any version named #{version}")
      end
    else
      display("#{app} has no versioned config vars.")
    end
  end

  # config:rollback VERSION
  #
  # roll back the config variables to an older version
  #
  #Example:
  #
  # $ heroku config:rollback 20140118042753
  # Rolling back example config vars to version 20140118042753... done
  #
  def rollback
    unless version = shift_argument
      error("Usage: heroku config:rollback VERSION\nMust specify VERSION.")
    end

    vars = api.get_config_vars(app).body
    _, versions_data = vars.detect {|k,v| k == 'HEROKU_CONFIG_VERSIONS'}

    if versions_data
      versions = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(versions_data)))

      if version_vars = versions[version]
        version_vars.reject! {|k,v| k =~ /HEROKU_POSTGRES/}
        action("Rolling back #{app} config vars to version #{version}") do
          api.put_config_vars(app, version_vars)
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
