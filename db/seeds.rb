# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

#--- topics
@topics = [
  {:name => "Arbeitsrecht"},
  {:name => "Agrarrecht"},
  {:name => "Bank- und Kapitalmarktrecht"},
  {:name => "Bau- und Architektenrecht"},
  {:name => "Erbrecht"},
  {:name => "Familienrecht"},
  {:name => "Handels- und Gesellschaftsrecht"},
  {:name => "für gewerblichen Rechtsschutz"},
  {:name => "Informationstechnologierecht"},
  {:name => "Insolvenzrecht"},
  {:name => "Medizinrecht"},
  {:name => "Miet- und Wohnungseigentumsrecht"},
  {:name => "Sozialrecht"},
  {:name => "Strafrecht"},
  {:name => "Steuerrecht"},
  {:name => "Transport- und Speditionsrecht"},
  {:name => "Urheber- und Medienrecht"},
  {:name => "Verkehrsrecht"},
  {:name => "Versicherungsrecht"},
  {:name => "Verwaltungsrecht"}
]
Topic.create(@topics) if Topic.count == 0

#--- bar associations
BarAssociation.create([                                               
  {:name =>  "Brandenburgische RAK"}, 
  {:name =>  "Hanseatische RAK Bremen"}, 
  {:name =>  "Hanseatische RAK Hamburg"}, 
  {:name =>  "Pfälzische RAK Zweibrücken"}, 
  {:name =>  "RAK Bamberg"}, 
  {:name => " RAK bei dem Bundesgerichtshof"}, 
  {:name =>  "RAK Berlin"}, 
  {:name =>  "RAK des Landes Sachsen-Anhalt"}, 
  {:name =>  "RAK des Saarlandes"}, 
  {:name => "RAK Düsseldorf"}, 
  {:name => "RAK Frankfurt"}, 
  {:name =>  "RAK Freiburg"}, 
  {:name => "RAK für den OLG-Bezirk Braunschweig"}, 
  {:name =>  "RAK für den OLG-Bezirk Celle"}, 
  {:name => "RAK für den OLG-Bezirk Hamm"}, 
  {:name =>  "RAK für den OLG-Bezirk München"}, 
  {:name =>  "RAK für den OLG-Bezirk Oldenburg"}, 
  {:name =>  "RAK Karlsruhe"}, 
  {:name =>  "RAK Kassel"}, 
  {:name =>  "RAK Koblenz"}, 
  {:name => "RAK Köln"}, 
  {:name => "RAK Mecklenburg-Vorpommern"}, 
  {:name =>  "RAK Nürnberg"}, 
  {:name =>  "RAK Sachsen"}, 
  {:name =>  "RAK Stuttgart"}, 
  {:name =>  "RAK Thüringen"}, 
  {:name =>  "RAK Tübingen"}, 
  {:name =>  "Schleswig-Holsteinische RAK"}
]) if BarAssociation.count == 0

#--- academic titles
[
  {:name => "Dr."},
  {:name => "Prof."},
  {:name => "Prof. Dr."},
  {:name => "kein Titel"}
].each do |row|
  at = AcademicTitle.create(row) unless AcademicTitle.find_by_name(row[:name])
end

#--- add products
if Product.count == 0

  # flex
  Product.create({
    :name => "Flex-Paket",
    :sku => "P001",
    :cents => 500,
    :currency => "EUR",
    :contacts => 1,
    :subscription => false
  })

  # 20er Paket
  Product.create({
    :name => "20er-Paket",
    :sku => "P020",
    :cents => 3490,
    :currency => "EUR",
    :contacts => 20,
    :subscription => false
  })

  # 40er Paket
  Product.create({
    :name => "40er-Paket",
    :sku => "P040",
    :cents => 6490,
    :currency => "EUR",
    :contacts => 40,
    :subscription => false
  })

  # Flat
  Product.create({
    :name => "Flat-Paket",
    :sku => "P999",
    :cents => 9490,
    :currency => "EUR",
    :subscription => false
  })

  # 20er Paket Subscription
  Product.create({
    :name => "20er-Paket Abo",
    :sku => "S020",
    :cents => 2490,
    :currency => "EUR",
    :contacts => 20,
    :subscription => true
  })

  # 40er Paket Subscription
  Product.create({
    :name => "40er-Paket Abo",
    :sku => "S040",
    :cents => 4490,
    :currency => "EUR",
    :contacts => 40,
    :subscription => true
  })

  # Flat Subscription
  Product.create({
    :name => "Flat-Paket Abo",
    :sku => "S999",
    :cents => 6490,
    :currency => "EUR",
    :subscription => true
  })

  puts "-> Products created."
  
end

#--- add a dummy Client, called "foo"
unless User.find_by_login("foo")
  user = User.new
  user.person = Client.new({
    :first_name => "Little",
    :last_name => "Foo",
    :email => "foo@example.com",
    :phone_number => "+49 (89) 123 4567",
    :gender => "m",
    :newsletter => true,
    :remedy_insured => true,
    :personal_address_attributes => {
      :street => "Männerstrasse",
      :street_number => "99",
      :city => "Ulm",
      :postal_code => "76543",
      :country_code => "DE"
    }
  })
  user.attributes = {
    :login => "foo",
    :email => 'foo@example.com',
    :email_confirmation => 'foo@example.com',
    :password => 'foobar',
    :password_confirmation => 'foobar'
  }
  
  user.register! if user.valid?
  user.activate! if user.valid?
  
  puts "-> Client user 'foo' created." unless user.new_record?
end

#--- add a dummy Advocate, called "bar"

unless User.find_by_login("bar")
  user = User.new
  user.person = Advocate.new({
    :first_name => "Mighty",
    :last_name => "Bar",
    :gender => 'm',
    :academic_title => AcademicTitle.prof_dr,
    :phone_number => '+49 89 123456',
    :bar_association => BarAssociation.first,
    :primary_expertise => Expertise.find_by_name("Arbeitsrecht"),
    :secondary_expertise => Expertise.find_by_name("Strafrecht"),
    :company_name => "Rechtsanwaltskanzlei Frauen",
    :company_url => "http://www.rechtsanwälte-frauen.tst",
    :newsletter => true,
    :profession_advocate => true,
    :profession_notary => true,
    :profession_cpa => true,
    :business_address_attributes => {
      :street => "Frauenstrasse",
      :street_number => "12",
      :city => "Bamberg",
      :postal_code => "96047",
      :country_code => "DE"
    }
  })
  
  user.attributes = {
    :login => "bar",
    :email => 'bar@example.com',
    :email_confirmation => 'bar@example.com',
    :password => 'foobar',
    :password_confirmation => 'foobar'
  }
  
  user.login = "bar"
  user.register! if user.valid?
  user.activate! if user.valid?
  
  puts "-> Advocate user 'bar' created." unless user.new_record?
end


#--- spoken languages
if SpokenLanguage.all.empty?
  priorities = %w(Deutsch Englisch Französisch Griechisch Italienisch Niederländisch Katalanisch Ungarisch Polnisch Portugiesisch Russisch Schwedisch Slowakisch Spanisch Tschechisch Türkisch)
  
  LocalizedLanguageSelect::localized_languages_array.each do |language|
    name = language.first
    code = language.last
    
    sl = SpokenLanguage.create(:code => code, :name => name, :priority => priorities.include?(name))
    puts "-> Spoken language '#{sl.name}' (#{sl.code}) created." unless sl.new_record?
  end
end


#--- vouchers
if PromotionContactVoucher.active.all.empty?
  PromotionContactVoucher.generate(20, :amount => 10)
  puts "-> Vouchers: "
  PromotionContactVoucher.active.each {|v| puts v.code}
  puts "created."
end

#--- paper invoice product
unless Product.find_by_sku("X001")
  Product.create({
    :name => "Rechnungsversand per Post in Papierform",
    :sku => "X001",
    :cents => 500,
    :currency => "EUR",
    :subscription => false
  }) 
  puts "-> 'Rechnungsversand per Post in Papierform' created."
end

#--- update product info
if p20 = Product.find_by_sku("P020")
  p20.update_attributes(:length_in_issues => 1, :subscription => true)
  puts "#{p20.name} updated."
end

if p40 = Product.find_by_sku("P040")
  p40.update_attributes(:length_in_issues => 1, :subscription => true)
  puts "#{p40.name} updated."
end

if p999 = Product.find_by_sku("P999")
  p999.update_attributes(:length_in_issues => 1, :subscription => true, :flat => true)
  puts "#{p999.name} updated."
end

if s20 = Product.find_by_sku("S020")
  s20.update_attributes(:length_in_issues => 12, :subscription => true)
  puts "#{s20.name} updated."
end

if s40 = Product.find_by_sku("S040")
  s40.update_attributes(:length_in_issues => 12, :contacts => 40, :subscription => true)
  puts "#{s40.name} updated."
end

if s999 = Product.find_by_sku("S999")
  s999.update_attributes(:length_in_issues => 12, :subscription => true, :flat => true)
  puts "#{s999.name} updated."
end

#--- Fix Topics to Expertise (Fachanwalt)
# Make all topics expertises
Topic.all.each do |topic|
  topic.update_attribute(:type, "Expertise") unless topic.is_a?(Expertise)
end

# add "Kein Fachanwalt"
if e = Topic.find_by_name("Kein Fachanwalt")
  e.update_attributes({:position => 0, :expertise_only => true})
else
  e = Expertise.create(:name => "Kein Fachanwalt", :expertise_only => true)
  e.update_attributes({:position => 0, :expertise_only => true})
end

#--- Fix products

# Kontakt Produkt
unless Product.find_by_sku("K001")
  Product.create({
    :name => "Zusätzlicher Kontakt",
    :sku => "K001",
    :cents => 500,
    :currency => "EUR",
    :contacts => 1,
    :subscription => false
  })
  puts "'Zusätzlicher Kontakt' Produkt erstellt"
end

if flex = Product.find_by_sku("P001")
  flex.update_attributes(:length_in_issues => 0, :subscription => true, :cents => 0, :contacts => 0)
  puts "#{flex.name} updated."
end

#--- Fix product's term days
if Product.columns.map(&:name).include?("term_in_days")
  Product.all.each do |product|
    unless product[:term_in_days]
      if product.sku.match(/^S([0-9]*)$/i)
        product.term_in_days = Product.anual_term_days
      elsif product.sku.match(/^P([0-9]*)$/i)
        product.term_in_days = Product.monthly_term_days
      end
      if product.changed?
        product.save! 
        puts "Product #{product.sku} updated term in days to #{product.term_in_days}"
      end
    end
  end
end

#--- duplicate expertise and topics
@topics.each do |item|
  if expertise = Expertise.find_by_name(item[:name])
    expertise.update_attributes({:expertise_only => true, :topic_only => false})
    if topic = Topic.find(:first, :conditions => ["topics.name = ? AND topics.topic_only = ? AND topics.expertise_only = ?", item[:name], true, false])
    else
      Topic.create({:name => expertise.name, :topic_only => true, :expertise_only => false})
    end
    puts "update expertise and duplicated #{expertise.name}"
  end
end
