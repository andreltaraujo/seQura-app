Rails.application.routes.draw do
	require 'sidekiq/web'

	Rails.application.routes.draw do
		mount Sidekiq::Web => '/sidekiq'
	end
	
end
