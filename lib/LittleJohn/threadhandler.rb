
## LittleJohn::ThreadHandler
#   Create your Class and include ThreadHandler
#    Then define @threads Hash in your Class with the following structure
# @threads = { 'threadName1' => {
#                'code' => Proc.new { _threadLoop_privateMethod_noTimer },
#                'thread' => nil },
#              'threadName2' => {
#                'code' => Proc.new { _threadLoop_privateMethod_withTimer },
#                'thread' => nil,
#                'timer' => nil } }
#
#  #pre_start and #pre_stop can hold any code that needs to be run prior
#   to starting or stopping the thread. Any post stop/start tasks can be
#   placed within your Class' code following start/stop.

module LittleJohn
  module ThreadHandler

    def start(threads=@threads.keys)
      state, running, stopped = status(threads)
      return state, running, stopped if state == true
      
      return if pre_start == false
      stopped.each do |name|
        puts "#{Time.now.utc} Starting thread: #{name}"
        params = @threads[name]
        params['thread'] = Thread.new do
          Thread.current.thread_variable_set('name', name)
          params['code'].call
        end
      end

      status(threads)
    end

    def stop(threads=@threads.keys)
      state, running, stopped = status(threads)
      return if running.empty?

      return if pre_start == false
      running.each do |name|
        puts "#{Time.now.utc} Stopping thread: #{name}"
        stop_object(name)
        @threads[name]['thread'].exit
        @threads[name]['thread'].join
      end

      status(threads)
    end

    def status(threads=@threads.keys)
      running, stopped = Array.new, Array.new
      invalid = threads.reject{ |k,v| @threads.keys.include?(k) }
      if invalid.any?
        puts "Invalid threads: #{invalid}"
        return [nil, invalid]
      end

      threads.each do |name|
        thread = @threads[name]['thread']
        if thread.nil?
          stopped << name
        elsif thread.alive?
          running << name
        else
          stopped << name
        end
      end

      status = stopped.any? ? false : true
      [status, running, stopped]
    end

    private
    def pre_start
      # Define any pre-start actions within the including Class#pre_start
      #  Return true || false
      return true
    end

    def pre_stop
      # Define any pre-stop actions within the including Class#pre_stop
      #  Return true || false
      return true
    end

    def stop_object(name)
      self.send(name).stop if self.instance_variables.include?(('@' + name).to_sym)
    end
  end  
end
