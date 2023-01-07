
module LittleJohn
  module Model
    attr_reader :data
    attr_reader :view
    attr_reader :params
    attr_reader :missing_keys

    def initialize(view, params, extends=nil)
      self.extend(extends) if extends
      @view, @params = view, params
      required_keys
      reload
    end

    def delete
      delete_children
      delete = @view.delete_one
      if delete.deleted_count > 0
        puts "Deleted #{@params['key']}|#{@_id}"
        nullify_values
        true
      else
        false
      end
    end

    def update(updates)
      updates = parse_updates(updates)
      return if updates.nil?
      begin
        @view.update_one(updates)
        parse_model
      rescue => e
        puts "Failed to update model: #{e}"
        false
      else
        true
      ensure
        reload
      end
    end

    def children
      found = Hash.new
      if children = @params['children']
        children['collections'].each do |col|
          c = Collection.new(col, search_ids)
          c.extend(LittleJohn::Collection)
          found[col] = c.all
        end
      end

      found
    end

    def summary(long=false)
      output = ["#{self.class}._id: #{@_id}"]
      @data.each do |k,v|
        output.push(" #{k}:\t#{v}")
      end

      puts output
      summary_children if long
    end

    def summary_children
      # output = Array.new
      if children.values.map(&:any?).any?
        children.each do |k,v|
          next if v.empty?
          puts "#{k.capitalize}"
          v.each do |c|
            c.summary
          end
        end
      end
      nil
    end

    def reload
      pre_reload
      parse_model
      post_reload
    end

    def updated?
      data = @data
      reload
      data != @data ? true : false
    end

    private
    def child_ids
      { @params['key'] => @_id }.merge(@ids)
    end

    def search_ids
      ids = { "ids.#{@params['key']}": @_id }
      @ids.each do |k,v|
        ids["ids.#{k.to_s}".to_sym] = v
      end
      ids
    end

    def parse_model
      return if @view.nil?
      @data = Helpers.parse_attributes(self, merge_defaults)
    end

    def merge_defaults
      view = @view.first || Hash.new
      if @data && remove = @data.keys.reject{|k| k if view[k] }
        remove.each {|k| self.instance_variable_set("@#{k}", nil) }
      end

      defaults = @params['private'] || Hash.new
      defaults.merge!(@params['public']) if @params['public']
      defaults.merge(view)
    end

    def required_keys
      view = @view.first || Hash.new
      @missing_keys = @params['requires'].reject do |k|
        view.keys.map(&:to_s).include?(k) && view[k] != nil
      end

      if @missing_keys.any?
        puts "Parameters requires keys: #{missing_keys.join(', ')}"
      end
    end

    def parse_updates(updates)
      if updates[:set] &&
         updates[:set].keys.map(&:to_s).grep(/env/).any?
        output = ["Collection: '#{@view.collection.name}' => _id: #{@_id}"]
        output << " ! Updating 'ids.env' is dangerous! Delete and recreate instead."
        output << "   |_ Updates: #{updates}"
        puts output
        return nil
      end

      if updates[:unset]
        missing = @params['requires'].reject { |k| ! updates[:unset].include?(k) }
        if missing.any?
          puts "Unable to unset required keys: #{missing.join(', ')}"
          return nil
        end
      end

      parsed = Array.new
      updates.each do |k, v|
        parsed.push({ :$set   => v }) if k.to_sym == :set
        parsed.push({ :$unset => v }) if k.to_sym == :unset
      end

      parsed
    end

    def delete_children
      children.each do |col, models|
        next if models.empty?
        puts "Cleaning #{col}"
        models.map(&:delete)
      end
    end

    def nullify_values
      @data.each_key { |k| @data[k] = nil }
      @params['requires'].each { |k| @data[k] = nil }
      @view = [@data]
      parse_model
    end

    class Collection
      def self.new(col, ids)
        @col, @ids = col, ids
        self
      end
    end

    def pre_reload
      # Define any pre-reload actions within the extending Class#pre_reload
    end

    def post_reload
      # Define any post-reload actions within the extending Class#post_reload
    end
  end
end
