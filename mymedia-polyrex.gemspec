Gem::Specification.new do |s|
  s.name = 'mymedia-polyrex'
  s.version = '0.1.0'
  s.summary = 'A MyMedia gem to publish a Polyrex file to a website.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/mymedia-polyrex.rb']
  s.add_runtime_dependency('mymedia', '~> 0.1', '>=0.1.1')
  s.signing_key = '../privatekeys/mymedia-polyrex.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/mymedia-polyrex'
end
