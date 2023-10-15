# README
	1. https://github.com/andreltaraujo/seQura-app.git

* Ruby version
		3.2.1
* Rails version
		7.0.8

* Instaled Gems
		money-rails
			Initialize with: rails generate money_rails:initializer
		sidekiq
			config_routes
			Need to config Redis to run background job
			run redis-server afer install
			start sidekiq
			run bundle exec sidekiq
		rspec-rails
			Initialize with: rails generate rspec:install
		factory-bot-rails

* Configuration
# Include FactoryBot sintax methods
	Include "FactoryBot", so we dont't need to include it in the spec test file.
	RSpec config:
	RSpec.configure do |config|
	config.include FactoryBot::Syntax::Methods
	E.g:
	subject { create(:disbursement) }
	instead of
	subject { FactoryBot.create(:disbursement) }

* Database creation
		PostgreSQL is chosen for its robustness and support for complex queries, suitable for handling financial data.

* How to run the test suite
	In root folder of the project run: bundle exec rspec

- The implementation:
	Did not consider taxes for calculations;
	Did not consider orders (state/status) for disbursements calculations;
	  e.g: canceled orders at the disbursements calculation process period;
	Did not consider disbursements (state/status) for flow tracking;
	Did not consider any kind of the other policy than those described in the requirements;

- Tecnical choices:
	Was reated a task to load the data provided (CSV file);
	Was created a Order Commission class to be responsible for unity order calculation process, persisting those to keep track.
	The logic for calculating disbursements is encapsulated within the DisbursementCalculator class, adhering to SOLID principles, enabling clean and maintainable code.Other class are responsible each for one part of the process. Lets break it down to it parts

	The Disbursement generator worker scheduled to run in background every day 8:00, is reponsible for find the Merchant eligile for disbursements that day. The implementation has considered all the orders of the day before (for daily frequency merchants) and the day before +6 days back to include all the orders to be processed that day for de weekly merchants.
	The implementation consired to include the orders of the "live_on" day of the past week, since the process run 8:00.
	Considering this, the system architecture is assumed to be scalable, to handle increased merchant orders and disbursements.
	For main maintainability aspects the implementation considered was keep as much as possible the responibilities separated. So we have, The CommissionGeneration, CommissionCalculator, CommmissionBuilder, and the same for Disbursements: DisbursementsGenerator, Disbursement Calculator and Disbursement Builder, as well yours Workers. In this aproach, Commission calculator is a separate class responsible for calculating commission fees based on order amounts. It follows the Single Responsibility Principle (SRP) and encapsulates the logic for determining the commission rate which is GetCommissionFee responsability.

	DisbursementCalculator uses CommissionCalculator to calculate the commission fee. This separation of concerns ensures that DisbursementCalculator focuses solely on the disbursement process, making the code cleaner and more maintainable

	Following the best practices, we choose to use rails money gem to deal with money as a integer intead of other type of data, as Float per example. Avoding using floating-point numbers (float) for monetary calculations due to their inherent precision issues. Floating-point arithmetic can result in inaccuracies in financial calculations. Using the gem we store the amounts in smaller units of the currency (cents) and perform calculations in these smaller units to avoid rounding issues.

	When dealing with commission fees, especially if they involve complex logic or are subject to change, it's a good practice to encapsulate this logic in its own class.This adheres to the Single Responsibility Principle (SRP) and makes the more modular and maintainable. A separate class dedicated to calculating commission fees can handle different fee structures, making it easier to modify or extend in the future without affecting the rest of the codebase.
	Ex. GetCommissionFee.

	Test Suits
	We choose Rspec, although the Minitest is the default test implementatio in Rails 7. It because the out put of Rspec, is more readable and the test more consistents.
	Wee did not implement the calculation of minimum monthlyt amount fee due of time.
	Commissions Task and Disbursement Task was used to calculated the CSV file data the result as follow:

| YEAR | Number of disbursements | Amount disbursed to merchants	| Amount of order fees | Number of monthly fees charged | Amount of monthly fee charged |
|------|-------------------------|--------------------------------|----------------------|--------------------------------|-------------------------------|
| 2022 |          1283           |       €11.596.211,27           |   €106.906,63        |                                |                               |
| 2023 |           881           |        €9.049.910,27           |    €83.185,32        |                                |                               |
|------|-------------------------|--------------------------------|----------------------|--------------------------------|-------------------------------|

