require 'rails_helper' # Make sure to adjust this based on your project's file structure

RSpec.describe DisbursementGenerator do
	let(:merchant) { create(:merchant, :weekly)}
	let(:orders) { create_list(:order, 7, :weekly_orders) }
	let(:generated_commissions) { create_list(:order_commission, 7, :with_orders) }
	let(:calculated_disbursement) {
		{ order_fee_amount: generated_commissions.sum(&:sequra_amount),
			amount: generated_commissions.sum(&:merchant_amount),
			currency: 'EUR'
		}
	}
	let(:disbursement) { create(:disbursement) }

	describe '#execute' do
		describe '.OrderCommissionGenerator' do
			describe '#execute' do
				context 'When merchant have orders to process' do
					it 'generate order commissions for disbursements' do
						allow(OrderCommissionGenerator).to receive(:execute).and_return(generated_commissions)
						expect(generated_commissions_no_orders.sum(&:merchant_amount_cents)).to eq(17626)
					end
				end
			end
		end

		describe '.OrderCommissionGenerator' do
			describe '#execute' do
				context 'When merchant have NO orders to process' do
					it 'Do NOT generate order commissions for disbursements' do
						allow(OrderCommissionGenerator).to receive(:execute).and_return(nil)
					end
				end
			end
		end

		describe '.DisbursementCalculator' do
			describe '#calculate' do
				context 'When the orders commission were properly generated' do
					it 'calculates the disbursement for generation' do
						disbursement_calculator = instance_double(DisbursementCalculator)
						allow(DisbursementCalculator).to receive(:new).with(generated_commissions).and_return(disbursement_calculator)
						allow(disbursement_calculator).to receive(:calculate).and_return(calculated_disbursement)
					
					end
				end
			end
		end

		describe '.Disbursement' do
			describe '#create' do
				context 'When the disbursement was properly calculated' do
					it 'creates the disbursement' do
						allow(Disbursement).to receive(:create).with(calculated_disbursement).and_return(disbursement)
						expect(disbursement).to be_a(Disbursement)
						expect(disbursement.reference).not_to be(nil)
						expect(disbursement.amount_cents).to eq(17626)
						expect(disbursement.order_fee_amount_cents).to eq(175)
						expect(orders.last.reload.disbursement_id).to eq(disbursement.id)
						expect(orders.last.reload.disbursement_reference).to eq(disbursement.reference)

					end
				end
			end
		end

		describe '#merchants_weekly_today' do
			context 'today is the merchant week day for disbursement' do
				it 'the merchant is selected for process' do
				allow(described_class).to receive(:merchants_weekly_today).and_return(merchant)
				expect(merchant.live_on).to eq(Date.today)
				end
			end
		end

		describe '#weekly_disbursements_dates' do
			context 'calculates disbursement period' do
				it 'generate the dates to fetch orders' do
				allow(described_class).to receive(:weekly_disbursements_dates).with(merchant).and_return({Date.today - 6.days => Date.today - 1.day})
				end
			end
		end
		
		describe "#fetch_orders_weekly" do
			context 'is the marchant day fo disbursements' do
				it 'select the orders for generation commissions' do
					dates = described_class.weekly_disbursements_dates(merchant)
					allow(described_class).to receive(:fetch_orders_weekly).with(merchant, dates).and_return(orders)
					expect(orders.count).to eq(7)
				end
			end
		end
	end
end
