require 'nokogiri'
require 'open-uri'

require './requester.rb'

class Crawler
	def initialize(requester_options = {})
		@requester = Requester.new(requester_options)
	end

	def scrape_doc doc, operations
		record = {}
		operations.each do |e|
			if e[3] == :xpath
				e[0].call(doc.xpath(e[1]), record)
			else
				e[0].call(doc.css(e[1]), record)
			end
		end
		return record
	end

	def scrape_page url, operations
		return scrape_doc(@requester.request(url), operations)
	end

	def crawl url_crawler, operations, store_function
		doc = nil
		while(url = url_crawler.next(doc))
			doc = @requester.request url
			store_lambda.call(scrape_doc(doc, operations))
		end
	end
end