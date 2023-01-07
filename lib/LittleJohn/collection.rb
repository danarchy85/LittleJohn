
module LittleJohn
  module Collection
    def initialize(col, ids=nil, limit=0)
      # col: MongoDB collection
      # ids: User :ids hash to control ownership
      # limit: default limit in #find_many
      @col, @ids, @limit = col, { ids: ids }, limit
    end

    def find_one(search=Hash.new, bind=true)
      search.merge!(@ids) if bind == true
      view = LittleJohn.mdb.q(@col, 'find', search)
      if view.any?
        if view.count > 1
          puts "Found multiple #{@col}. Narrow the search."
          return nil
        else
          Model.new(view, params, @extends)
        end
      else
        nil
      end
    end

    def find_many(search=Hash.new)
      search.merge!(@ids)
      LittleJohn.mdb.q(@col, 'find', search)
        .limit(@limit || 0)
        .collect do |doc|
        find_one({ _id: doc['_id'] }, bind=false)
      end
    end

    def all
      find_many
    end

    def first
      all.first
    end

    def count
      all.count
    end

    def sort_by(key=:created)
      all.sort_by { |a| a.send(key.to_s) }
    end

    def create(doc=Hash.new, verbose=true)
      if doc.empty?
        puts "No arguments were provided! Requires: #{params['requires'].join(', ')}"
        return false
      end

      search = Hash.new
      params['requires'].each { |r| search[r.to_sym] = doc[r.to_sym] }
      search.merge!({ 'ids.u_id': @ids[:ids]['u_id'] }) if @ids.values.any?

      model = find_one(search, bind=false)
      if model
        output  = "Model already exists! Update it instead: "
        output += " (env: #{model.ids['env']}): " if @ids.values.any? && model.ids['env']
        output += doc.collect{|k,v| "#{k.to_s}: #{v}" }.join(' | ')
        puts output if verbose
        model
      else
        doc.merge!(@ids) if @ids.values.any?
        doc[:created] = Time.now.utc
        id = LittleJohn.mdb.q(@col, 'insert_one', doc).inserted_id
        model = find_one({ '_id' => id })
        if model.missing_keys.any?
          model.delete
          false
        else
          post_create(model)
          model
        end
      end
    end

    private
    def params
      params = YAML.load_file(File.dirname(__FILE__) + '/collection/params.yml')
      params[@col] || params['defaults'] || { 'requires' => [], 'private' => {}, 'public' => {} }
    end

    class Model
      require_relative "collection/model"
      include LittleJohn::Model
    end

    def post_create(model)
      # Define any post-create actions within the including Class#post_create
      #  Return true || nil
      return true
    end
  end
end
