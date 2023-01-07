
require "net/smtp"
require "erb"

module LittleJohn
  class SMTP
    attr_reader :message
    attr_reader :variables

    def initialize(config)
      return nil if config.nil?
      load_smtp_config(config)
    end

    def send(from, to, subject, body, template='basic')
      return if ! enabled?
      generate_variables(from, to, subject, body)
      parse_message(template)
      send_message
    end

    private
    def parse_message(template)
      path = File.dirname(__FILE__) + '/smtp/'
      source = path + template + '.erb'

      @message = ERB.new(File.read(source), nil, '-').result(binding)
    end

    def generate_variables(from, to, subject, body)
      femail, fname = from.split(/[<,>]/).reverse
      temail, tname = to.split(/[<,>]/).reverse
      @variables = { 'from'    => from,
                     'to'      => to,
                     'femail'  => femail,
                     'fname'   => fname,
                     'temail'  => temail,
                     'tname'   => tname,
                     'subject' => subject,
                     'body'    => body }
    end

    def send_message
      smtp = Net::SMTP.new(@hostname, @port)
      i, retries = 0, 5

      begin
        i += 1
        smtp.enable_starttls if @starttls
        smtp.start('littlejohn.danarchy.me',
                   @username,
                   @password,
                   @auth_method)
        smtp.send_message(@message,
                          @variables['femail'],
                          @variables['temail'])
      rescue Exception => e
        puts "SMTP failed to email #{@variables['temail']} => '#{e}'"
        if i < retries
          sleep(5) ; retry
        elsif i == retries
          puts "Failed to email #{@variables['temail']} after #{i} retries!"
        end
      ensure
        smtp.finish if smtp.started?
      end

      smtp
    end

    def load_smtp_config(config)
      Helpers.parse_attributes(self, config)
    end

    def enabled?
      ! @hostname.nil?
    end

    def auth_method
      @auth.nil? ? :login : @auth.to_sym
    end
  end
end
