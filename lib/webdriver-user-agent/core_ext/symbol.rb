
if RUBY_VERSION =~ /1\.8/
  class Symbol
    def downcase
      self.to_s.downcase.to_sym
    end
  end
end
