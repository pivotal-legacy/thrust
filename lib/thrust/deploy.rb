class Thrust::Deploy
  def self.make(app_config, distribution_config, provisioning_search_query)
    build_configuration = distribution_config['configuration']
    x_code_tools = Thrust::XCodeTools.new($stdout, build_configuration, app_config.build_dir, app_config.config['project_name'])
    git = Thrust::Git.new($stdout)
    testflight = Thrust::Testflight.new($stdout, $stdin, app_config.config['api_token'], distribution_config['token'])

    new($stdout, x_code_tools, git, testflight, provisioning_search_query, app_config, distribution_config)
  end

  def initialize(out, x_code_tools, git, testflight, provisioning_search_query, app_config, distribution_config)
    @out = out
    @x_code_tools = x_code_tools
    @git = git
    @testflight = testflight
    @provisioning_search_query = provisioning_search_query
    @app_config = app_config
    @distribution_config = distribution_config
  end

  def run
    @git.ensure_clean
    @x_code_tools.change_build_number(@git.current_commit)
    app_name = @app_config.config['app_name']
    ipa_file = @x_code_tools.cleanly_create_ipa(app_name, app_name, @app_config.config['identity'], @provisioning_search_query)
    @testflight.upload(@x_code_tools.build_configuration_directory, app_name, ipa_file, @distribution_config['notify'], @distribution_config['default_list'])
    @git.reset
  end
end