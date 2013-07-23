Gem::Specification.new do |s|
  s.name        = 'reid'
  s.version     = '0.0.7'
  s.date        = '2013-07-23'
  s.summary     = 'Reid is a gem to help structure web scraping.'
  s.authors     = ['Dan Breczinski']
  s.email       = 'pt2323@gmail.com'
  s.files       = ['lib/reid.rb', 'lib/requester.rb']

  s.add_dependency('nokogiri')
end