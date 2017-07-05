# encoding: utf-8


title 'php-fpm modules'

php_modules = [
  'curl',
  'date',
  'json',
  'xml',
  'xmlreader',
  'xsl',
]

control 'php-fpm-modules' do
  impact 1.0
  title 'php-fpm modules should be compiled in php'
  desc 'php-fpm should have defined modules complied in'

  only_if do
    command('php-fpm').exist?
  end

  php_modules.each { |phpmod|
    describe command('php-fpm -m') do
      its('stdout') { should match (phpmod)}
    end
  }
end

