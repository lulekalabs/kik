module Advocate::RecommendationsHelper

  def preview_receiver_title_and_name
    person = @recommendation.to_receiver
    result = []
    result << (person && person.academic_title ? person.academic_title.name : "[Titel des Empfängers]")
    result << (person.first_name.blank? || "#{person.first_name}".index("*") ? "[Vorname des Empfängers]" : person.first_name)
    result << (person.last_name.blank? || "#{person.last_name}".index("*") ? "[Nachname des Empfängers]" : person.last_name)
    return result.join(" ")
  end

  def preview_sender_title_and_name
    person = @recommendation.to_sender
    result = []
#    result << (person && person.academic_title ? person.academic_title.name : "[Titel des Empfehlenden]")
    result << (person && person.academic_title ? person.academic_title.name : "")
    result << (person.first_name.blank? || "#{person.first_name}".index("*") ? "[Vorname des Empfehlenden]" : person.first_name)
    result << (person.last_name.blank? || "#{person.last_name}".index("*") ? "[Nachname des Empfehlenden]" : person.last_name)
    return result.join(" ")
  end

  def preview_receiver_salutation_and_title_and_name
    person = @recommendation.to_receiver
    result = []
    result << (person.gender.blank? ? "[Anrede des Empfängers]" : (person.male? ? "Herr" : "Frau"))
    result << (person && person.academic_title ? person.academic_title.name : "[Titel des Empfängers]")
#    result << (person.first_name.blank? || "#{person.first_name}".index("*") ? "[Vorname des Empfängers]" : person.first_name)
    result << (person.last_name.blank? || "#{person.last_name}".index("*") ? "[Nachname des Empfängers]" : person.last_name)
    return result.join(" ")
  end
  
end
