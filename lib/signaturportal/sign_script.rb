# sudo port install ruby rubygems
# sudo gem install soap4r


#require "rubygems"
require 'signaturportal/default_driver.rb'

raise 'provide a pdf to get it signed' if ARGV.first.nil?

username = 'YOUR-USERNAME' # Username
gateway_passwort = 'YOUR-PASSWORD' # Gateway-Passwort
kontonr  = 'YOUR-KONTONR'  # Accountnummer/Kontonummer

path_to_file = ARGV.first
print "Sign the pdf..."
obj = MyServiceHandler.new
signed_pdf = obj.sign(username, gateway_passwort, kontonr, 'rechnung_signiert.pdf', (File.open(path_to_file, "r").read))
path_to_file = path_to_file.split('.')
path_to_file[-2] << '-signed'
path_to_file = path_to_file.join('.')

File.open(path_to_file, "w") do |back_out|
  back_out << signed_pdf
end

puts 'Balance: ' + "#{obj.balance(username, gateway_passwort, kontonr)}"

print "done\n"
