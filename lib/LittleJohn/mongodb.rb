
require 'mongo'
require_relative "mongodb/indexes"

module LittleJohn
  class MongoDB
    attr_reader :client

    ##
    # MongoDB Config:
    #   app.config['mongodb'] = {
    #     'hosts' => ['127.0.0.1:27017'],
    #     'settings' => {
    #       # required settings
    #       'database' => 'db_name',
    #       'user'     => 'db_user',
    #       'password' => 'db_pass
    #       # extra settings may be added here, for example:
    #       'max_pool_size' => 25
    #     }
    #   }
    #

    def initialize(config=nil)
      return nil if config.nil?
      load_mongodb_config(config)

      Mongo::Logger.logger.level = Logger::FATAL
      @client = new_client

      generate_indexes
      @client
    end

    ##
    # DB call on given collection with action, query, and updates if any.
    #
    # Queries other than a 'find' or 'aggregate' will be ran through a transaction
    #
    # Inputs:
    #   collection (String): 'quotes'
    #   action     (String): ['find','aggregate','drop','update_one','update_many','insert_one','insert_many'..etc]
    #   query      (Hash or Array[for aggregate]): { 'symbol' => 'SYM' }
    #   updates: symbol keys
    #     set   (Hash):  { 'param' => 'value' }
    #     unset (Array): ['param1','param2']

    def q(collection, action, query=Hash.new, updates=Hash.new)
      u, output = Array.new, Array.new
      updates.each do |k, v|
        u.push({ :$set   => v }) if k == :set
        u.push({ :$unset => v }) if k == :unset
      end

      args = query.nil? ? [{}] : [query]
      args.push(u) if u.any?

      transaction = %w[find aggregate].include?(action) ? false : true
      begin
        wait_for_connection
        session = @client.start_session

        if transaction
          session.with_transaction do
            @client[collection].send(action, *args)
          end
        else
          @client[collection].send(action, *args)
        end
      rescue Mongo::Error => e
        output << "MongoDB Error: collection: #{collection} | action: #{action}"
        output << "#{e.class} => #{e.message}"
        output << backtrace
        puts output
        if @client.cluster.servers.empty?
          puts "MongoDB: No servers available in cluster!\n\n"
          wait_for_connection
          new_client
          retry
        end
      ensure
        session.end_session if session
        close_client
      end
    end

    def new_client
      close_client if @client
      @client = Mongo::Client.new(@config['hosts'], @config['settings'])
    end

    def close_client
      @client.close if @client
    end

    def wait_for_connection
      until connection_alive?(verbose=true)
        sleep(5)
        new_client
      end
    end

    def connection_alive?(verbose=true)
      output = Array.new
      begin
        @client.collections
        @client.cluster.servers.any?
      rescue Mongo::Error => e
        output << "#{e.class}:=> Failed to connect to MongoDB!"
        output << backtrace
        if @client.cluster.servers.empty?
          output << "MongoDB: No servers available in cluster!\n\n"
        end

        puts output if verbose
        false
      end
    end

    private
    def load_mongodb_config(config)
      @config = config
      @config['settings'] = { 'max_pool_size' => 25 }
                              .merge(@config['settings'])

      index_yaml = File.expand_path('../../config/', __dir__) + '/indexes.yml'
      @indexes = File.exist?(index_yaml) ?
                   YAML.load_file(index_yaml) : Hash.new
    end

    def backtrace
      caller_locations.collect do |cl|
        "\t#{cl.path}:#{cl.lineno}:in #{cl.label}" if cl.path =~ /LittleJohn/
      end.compact
    end
  end
end
