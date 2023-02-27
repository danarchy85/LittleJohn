
require 'yaml'

module LittleJohn
  module Config
    attr_reader :cfgdir
    attr_reader :cfgfile
    attr_reader :debug
    attr_reader :logs
    attr_reader :mdb
    attr_reader :http
    attr_reader :smtp

    def initialize_config
      puts 'Initializing ' + self.name
      load_config
      load_smtp
      load_http
      load_mongodb
    end

    def reload_config
      load_config
      load_smtp
    end

    # def save_config
    #   File.write(@cfgfile, @config.to_yaml)
    #   load_config
    # end

    private
    def load_config
      @cfgdir = File.realpath(ENV['HOME']) + '/.' + self.name.downcase
      Dir.exist?(@cfgdir) || Dir.mkdir(@cfgdir)
      puts "#{self.name} configuration directory: #{@cfgdir}"

      @cfgfile = @cfgdir + '/config.yml'
      File.exist?(@cfgfile) || File.write(@cfgfile, Hash.new.to_yaml)

      @config = YAML.load_file(@cfgfile)
      @config['env'] ||= nil
      Helpers.parse_attributes(self, @config, ['mongodb'])
    end

    def load_mongodb
      @mdb = @config['mongodb'] ? MongoDB.new(@config['mongodb']) : nil
    end

    def load_http
      @http = HTTP.new
    end

    def load_smtp
      @smtp = @config['smtp'] ? SMTP.new(@config['smtp']) : nil
    end
  end
end
