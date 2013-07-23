## About

Crawler and its sister class requester are simple classes to help structure web scraping tasks.

Typical usage for a single-page scrape involves defining array of xpath or css Nokogiri selectors and one or more first-class functions (in the form of lambda(s) and/or proc(s)). Requester than iterates the array, selecting the element and passing them to your function. Your function should take two arguments. One is the element selected by the Nokogiri slecector, the second is a hash where you can save whatever you're scraping from that particular selection (this record is returned to you after the scrape).

Multipage scrapes include require you to build a page iterator and allow you to pass a persist method to... persist your record (see specifications and example below.)

Crawler uses Requester which can be used to throttle requests, backoff and log request errors. See Requester documentaiton for details

## Example usage
```ruby
require 'crawler.rb'

requester_options = {
	:min_request_interval => 1,
	:max_backoff_time => 60
	#...
}

crawler = Crawler.new(requester_options)

##############################
# 	Single page scrape
##############################

operations = [
	[
		Proc.new{|element, record| record[:title] = element.xpath('//title').text},
		'//head',
		:xpath
	],
	[
		Proc.new{|element, record| record[:paragraph] = element.css('p').text},
		'body',
		:css
	]
]

 record = crawler.scrape_page('http://example.iana.org/', operations)

 p record[:title] #=> "Example Domain"


##############################
# 	Using crawl method
##############################

class Url_iter
	def initialize
		@urls = ['http://example.iana.org/',
				 'http://www.iana.org/domains/special']
		@current = 0
	end
	def next(doc)
		#This method should return urls until all urls are
		#processed, then it should return nil.
		#
		#if you are iterating though multiple pages, etc.
		#you can check the Nokogiri document from your previous
		#request to determine if you've reached the last
		#page or whatever.
		#nil is passed on the first call
		if @current == 2
			@current = 0
			return nil
		else
			@current += 1
			return @urls[@current - 1]
		end
	end
end

persist_method = lambda do |record|
	#this is where you handle checking and persisting your record
	p 'I should be storing ' + record[:title]
end

crawler.crawl(Url_iter.new, operations, persist_method)

#=> "I should be storing Example Domain"
#=> "I should be storing Iana..."
```

## Installation

`gem install crawler`

## Intialization

Crawler takes an options hash for initializing a Requester object. See Requester doucmentation for details. Requester handles backing off if there are request errors. Requester has default options so you aren't requried to specify anthing.

## Method reference

#### `scrape_page(url, operations)`

Takes the url you want to scrape and a 2D array.

Returns a hash.
	
Each array within the 2D array should have three items (the first dimension of the 'x' specifies the element of operations. You can pass multiple operations over the same page):
* `operations[x][0]` is an xpath or css selector.
* `operations[x][1]` is a proc or lambda. `operations[x][1]` is passed the element(s) returned when `operations[x][0]` is applied to the Nokogiri document for the passed url. The proc or lambda passed as the second element (`operations[x][1]`) should accept two arguments. The first argument represents the element(s) that will be returned when `operations[x][0]` is applied to the Nokogiri document. The second argument is a hash. This is the hash that is ultimately returned by the scrape_page method and should be used to store any elements from the selection that you want returned/persisted.
* `operations[x][2]` is a symbol flag which can be either `:css` or `:xpath` depending on whether `operations[x][0]` is a css or xpath selector.

If there are multiple arrays contained in the 2D array, they will all be evaluated in order. 

The second argument passed to the the proc or lambda is the same hash so everything added to this hash by all proc/lambdas will be returned by the scrape_page method.

#### `scrape_doc(doc, operations)`

Same as scrape_page except it takes a Nokogiri doc instead of an url. (In case you want to handle the page request outside of Crawler)

#### `crawl(url_crawler, operations, store_function)`

Takes an object, 2D array, and a proc/lambda

`url_cralwer` must be an object that has a next method that accepts one argument. Next should return the next url to crawl or Nil once the crawl is complete. Next will be passed the Nokogiri document from the previous request or nil if it is the first request. This allows you to check the Nokogiri document from your previous request in case it is relevant to determining the next url which will be returned.

`operations` is a 2D array following the specification defined in the `scrape_page` method documentation. These methods are applied to each page.

`store_function` is a proc or lambda which receiveds the hash generated by the proc/lambdas in your operations array. This is typically used for checking and storing scraped data.

## Requester documentation

################################################################################

							ABOUT

################################################################################

 Requester is a a small class to use in conjunction with Nokogiri to perform
	request dampering and exponential backoffs when Nokogiri runs into an error
	when making a request.

################################################################################

							Dependencies

################################################################################

Requester requires Nokogiri and open-uri

################################################################################

							Method/usage

################################################################################

request(url)
	Takes a string url, returns a Nokogiri document or raises error if
		max_backoff_time is set during initializaing and is excieded.

Usage:
	require 'open-uri'

	options = {
		:min_request_interval => 5.0,
		:max_backoff_time => 60
		#...
	}
	
	r = Requester.new(options)
	doc = r.request('http://www.example.com')
	puts doc.css('title').text

################################################################################

							Initialize / options hash

################################################################################

Requester takes an optional options hash. Below are the options and their 
	defaults.

	:error_log
		Set to either a MongoDB collection or false. Default is false.
		If set to a collection, the time and error message for the Nokogiri
			request error will be saved to this collection. (It is advisable
			to use a capped collection)

	:intitial_delay
		Set to number.
		Default is 1.0
		After the first delay, Requester will wait this amount of seconds
			before making the next request.
  
	:max_backoff_time
		Set to either number of seconds or false. Default is false.
		If false, there is no maximum backoff time. Requester will continue
			at an exponentially diminishing rate.
		If set to a number, Requester will raise an error once it reaches
			that number of seconds. Note, this is the number since the last
			request, not the cumulative seconds. So, for instance, if you
			set this to 600 (10 minutes) and started with 2 seconds between
			requests, Requester would not stop making requests until there
			was 600 seconds between two consecutive requests.

	:min_request_interval
		Set to either a number of seconds or false. Default is false.
		If false, no dampering of requests will occur.
		If set to a number, each request will wait min_request_interval
			until making another request

	:multiplicand
		Set to number.
		Default is 1.3
		When there is an error with the request, Requester will wait the 
			previous back off time, times this amount.

################################################################################