Gem::Specification.new do |s|
  s.name        = 'Reid'
  s.version     = '0.0.5'
  s.date        = '2013-04-28'
  s.summary     = 'Reid is a gem to help structure web scraping.'
  s.authors     = ['Dan Breczinski']
  s.email       = 'pt2323@gmail.com'
  s.files       = ['lib/reid.rb', 'lib/requester.rb']

  s.add_dependency('nokogiri')
end