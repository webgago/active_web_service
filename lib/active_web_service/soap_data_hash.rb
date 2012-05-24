class SoapDataHash < Hash
  def initialize(*)
    super
    self.default_proc = lambda { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
  end
end