module Commissions
  class CommissionsTask
    def self.execute
			merchant_ids = Merchant.all.pluck(:id)
			merchant_ids.each do |merchant_id|
				merchant_reference = Merchant.find(merchant_id).reference
				if merchant_reference.blank?
					Rails.logger.info("[Commissions::CommissionsTask] - Merchant reference is required")
					return
				end
				Rails.logger.info("[Commissions::CommissionsTask] - Starting process...")
				Rails.logger.info("[Commissions::CommissionsTask] - Merchant reference: #{merchant_reference}")
				count = 0
				Order.joins(:merchant).where("merchant_reference = ?", merchant_reference).find_each do |order| 
					OrderCommissionGeneratorWorker.perform_async(order.id)
					count += 1
				end
				Rails.logger.info("[Commissions::CommissionsTask] - #{count} registers for #{merchant_reference} to be processed")
			end
      Rails.logger.info("[Commissions::CommissionsTask] - Process finished")
    end
  end
end
22537370