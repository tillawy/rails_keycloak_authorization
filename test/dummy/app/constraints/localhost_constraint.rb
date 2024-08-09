class LocalhostConstraint
  def matches?(request)
    request.ip == "127.0.0.1"
  end
end