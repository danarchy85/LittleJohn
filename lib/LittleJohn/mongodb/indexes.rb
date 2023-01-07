
module LittleJohn
  #module Config
    class MongoDB
      def generate_indexes(rebuild=false)
        return if @indexes.empty?
        wait_for_connection
        @indexes.each do |collection, indexes|
          indexes.each do |index|
            q(collection, 'create') if ! @client.database.collection_names.include?(collection)

            exists = q(collection, 'indexes').get(index['name'])
            if exists.nil?
              create_index(collection, index)
            elsif rebuild && exists['key'] != index['key']
              remove_index(collection, index['name'])
              create_index(collection, index)
            end
          end
        end
      end

      def remove_indexes(collections=indexes.keys)
        collections.each do |collection|
          next if ! @client.database.collection_names.include?(collection)
          puts "Removing all indexes on #{collection}"
          q(collection, 'indexes').drop_all
        end
      end

      private
      def create_index(collection, index)
        opts = { name: index['name'] } if index['name']
        if index.keys.include?('options')
          opts = Helpers.modify_hash_keys(opts.merge(index['options']),
                                       'convert', 'to_sym')
        end

        keys = index['key'].collect{|k,v| "#{k} => #{v}" }
        puts "Creating index: #{collection}.#{index['name']}: #{keys.join(', ')}"
        q(collection, 'indexes').create_one(index['key'], opts)
      end

      def remove_index(collection, name)
        puts "Removing index: #{collection}.#{name}"
        q(collection, 'indexes').drop_one(name)
      end
    end
  #end
end
