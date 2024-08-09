class LocalhostConstraint
  def self.matches?(request)
    request.ip == "127.0.0.1"
  end
end