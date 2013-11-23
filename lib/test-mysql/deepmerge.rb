class Hash
  def deep_merge hash
    v = dup
    hash.keys.each do |k|
      if hash[k].is_a? Hash and self[k].is_a? Hash
        v[k] = v[k].deep_merge(hash[k])
      else
        v[k] = hash[k]
      end
    end
    return v
  end
end

