require 'nokogiri'
require 'open-uri'

class Requester
	def initialize(options = {})
		@min_request_interval=(options[:min_request_interval] || false)
		@error_log = (options[:error_log] || false)
		@max_backoff_time = (options[:max_backoff_time] || false)
		@initial_delay = (options[:intial_delay] || 1.0)
		@multiplicand = (options[:multiplicand] || 1.3)
		@previous_request = (@min_request_interval && Time.now)
	end

	def request(url, time = false)
		if !time then if @min_request_interval then damper end end
		begin
			return Nokogiri::HTML(open(url))
		rescue Exception => e
			if @error_record
				error_record = {:time => Time.now, :message =>e.message}
				@error_log.insert(error_record)
			end
			unless time
				sleep @intial_delay
				return request url, @initial_delay * @multiplicand
			else
				if (!@max_backoff_time || (time < @max_backoff_time))
					sleep time
					return request url, time * @multiplicand
				else
					raise "Problem with request. Max backoff time exceided."
				end
			end
		end
	end

	def damper()
		if	(Time.now - @previous_request < @min_request_interval)
			sleep(@min_request_interval - (Time.now - @previous_request))
		end
		@previous_request = Time.now
	end
end