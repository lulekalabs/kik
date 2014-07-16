module Client::Account::StoresHelper
  def view_memorizes_advocates
    current_user.person.memorizes.each do |memorize|
       @advocate =  memorize.advocate_profile
      yield memorize
    end
  end
end
