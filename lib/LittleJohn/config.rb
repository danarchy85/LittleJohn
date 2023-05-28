
require 'yaml'

module LittleJohn
  module Config
    attr_reader :cfgdir
    attr_reader :cfgfile
    attr_reader :logger
    attr_reader :debug
    attr_reader :mdb
    attr_reader :http
    attr_reader :smtp

    def initialize_config
      puts 'Initializing ' + self.name
      load_config
      load_logs
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

      @config = YAML.load_file(@cfgfile) || Hash.new
      @config['env'] ||= nil
      Helpers.parse_attributes(self, @config, ['mongodb'])
    end

    def load_logs
      @config['logger'] ||= Hash.new
      logdir  = @cfgdir + '/logs'
      logfile = @config['logger']['log_file']
      Dir.exist?(logdir) || Dir.mkdir(logdir)

      logdev = if ! logfile || logfile == 'STDOUT'
                 puts 'STDOUT'
                 STDOUT
               elsif logfile == true
                 logdir + "/#{self.name.downcase}.log"
               else
                 logdir + '/' + @config['logger']['log_file']
               end

      puts "Logging to: #{logdev}"
      log_age  = @config['logger']['log_age']  || 'daily'
      log_size = @config['logger']['log_size'] || 1048576
      @logger = Logger.new(logdev, shift_age = log_age, shift_size = log_size)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "{ \"datetime\": \"#{datetime}\", \"level\": \"#{severity}\", \"message\": \"#{msg}\" }\n"
      end
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
