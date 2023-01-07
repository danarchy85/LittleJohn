
class Helpers
  def self.parse_attributes(c, hash, exclude=Array.new)
    hash.each do |k,v|
      next if exclude.include?(k)

      if v.class == String
        if v =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}T/
          v = Time.parse(v)
        elsif v =~ /\.0{8}$/
          v = v.to_i
        elsif v =~ /[0-9]\.[0-9]/
          v = v.to_f
        end
      end

      hash[k] = v
      c.singleton_class.class_eval { attr_reader k.to_sym }
      c.instance_variable_set("@#{k}", v)
    end
  end

  def self.modify_hash_keys(hash, action, mod, exclude=Array.new)
    # action == 'append' || 'prepend' || 'convert'
    # mod == string to append or prepend or conversion method (to_s, to_sym)
    if ! %w[append prepend convert].include?(action)
      puts 'Action can only be: append, prepend, or convert'
      return hash
    elsif action == 'convert' && ! %w[to_s to_sym].include?(mod)
      puts 'Convert modifications can only be: to_s or to_sym'
      return hash
    end

    h = hash.map do |k, v|
      next if exclude.include?(k)
      if action == 'append'
        [k + mod, v]
      elsif action == 'prepend'
        [mod + k, v]
      elsif action == 'convert'
        [k.send(mod), v]
      end
    end
    Hash[h]
  end

  def self.array_to_numarray(objects)
    numbered_array = {}
    
    objects.each.with_index(1) do |item, id|
      numbered_array[id] = item
    end

    numbered_array
  end

  def self.hash_to_numhash(hash)
    numbered_hash = {}

    hash.map.with_index(1) do | (k, v), index |
      numbered_hash[index] = {k => v}
    end

    numbered_hash
  end

  def self.object_to_hash(object)
    return nil if !object
    object.all_attributes
  end

  def self.objects_to_numhash(objects)
    return nil if !objects
    numbered_object_hash = {}

    objects.map.with_index(1) do | obj, index |
      numbered_object_hash[index] = obj.all_attributes
    end

    numbered_object_hash
  end

  def self.hash_largest_key(hash)
    hash.keys.map(&:to_s).max_by(&:size)
  end

  def self.hash_largest_value(hash)
    hash.values.map(&:to_s).max_by(&:size)
  end

  def self.hash_largest_nested_key(hash)
    hash.each_value.flat_map(&:keys).max_by(&:size)
  end

  def self.hash_largest_nested_value(hash)
    values = hash.each_value.flat_map(&:values)
    values.compact! if values.include?(nil)
    values.max_by(&:size)
  end

  def self.check_nested_hash_value(hash, key, value)
    check = false

    hash.each_value do |val|
      check = true if val[key].end_with?(value)
    end

    check
  end

  def self.hash_symbols_to_strings(hash)
    new_hash = Hash.new
    hash.each do |key, val|
      if val.class == Hash
        new_hash[key.to_s] = Hash.new
        val.each do |k, v|
          new_hash[key.to_s][k.to_s] = v
        end
      else
        new_hash[key.to_s] = val
      end
    end

    new_hash
  end
end
