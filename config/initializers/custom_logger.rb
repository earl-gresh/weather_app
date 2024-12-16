module CustomLogger
  def log(severity = :debug, *args, &blk)
    if block_given?
      Rails.logger.public_send(severity, blk.call)
    else
      Rails.logger.public_send(severity, *args)
    end
  end
end
