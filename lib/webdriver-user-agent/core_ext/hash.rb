class Hash
  DEEP_SYMBOLIZE_KEYS_SYMBOLS = [:deep_symbolize_keys, :deep_symbolize_keys!].freeze
  
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
  
  def method_missing(sym, *args)
    super unless DEEP_SYMBOLIZE_KEYS_SYMBOLS.include?(sym)
    
    self.send("alias_#{sym}")
  end
  
  private
  def alias_deep_symbolize_keys!
    alias_hash_deep_symbolize_keys!(self)
  end
  
  def alias_deep_symbolize_keys
    alias_hash_deep_symbolize_keys!(self.deep_copy)
  end
  
  def alias_hash_deep_symbolize_keys!(h)
    h.keys.each do |k|
      ks    = k.respond_to?(:to_sym) ? k.to_sym : k
      h[ks] = h.delete k
      alias_hash_deep_symbolize_keys! h[ks] if h[ks].kind_of? Hash
    end
    
    h
  end # https://stackoverflow.com/a/8379653/1651458
end
