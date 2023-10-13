class DisbursementGeneratorWorker
  include Sidekiq::Worker

  def perform
		Rails.logger.info("[#{self.class.name}][Starting generation...]")
    DisbursementGenerator.new.execute
    Rails.logger.info("[#{self.class.name}][Generation finished. ] #{Time.now.utc.to_s}")
  rescue StandardError => e
    Rails.logger.error("[#{self.class.name}][Error] #{e.message}")
    Rails.logger.error("[#{self.class.name}][Error] Backtrace: #{e.backtrace}")
  end
end
