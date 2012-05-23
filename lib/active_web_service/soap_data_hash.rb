class SoapDataHash < Hash
  def initialize(*)
    self.default_proc = lambda { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    super
  end
end