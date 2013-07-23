Gem::Specification.new do |s|
  s.name        = 'reid'
  s.version     = '0.0.8'
  s.date        = '2013-07-23'
  s.description = 'Reid is a simple tool for crawling web pages and throttling requests'
  s.license 	= 'MIT (http://opensource.org/licenses/MIT)'
  s.homepage	= 'https://github.com/danpaul/reid'
  s.summary     = 'Reid is a gem to help structure web scraping.'
  s.authors     = ['Dan Breczinski']
  s.email       = 'pt2323@gmail.com'
  s.files       = ['lib/reid.rb', 'lib/requester.rb']
  s.add_dependency('nokogiri', '~>1.5')
end