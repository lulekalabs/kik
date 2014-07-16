class Client::Account::StoresController < Client::Account::ClientAccountApplicationController
  def index
    
  end  
  
  def add
    advocate = Person.find( params[:id])
    # TODO sicher stellen ob der anwalt auch benutzt werden darf.
    if advocate.is_a?( Advocate )
      memorize = current_user.person.memorizes.find_by_advocate_id( params[:hid] )
      Memorize.create( :person_id => current_user.person.id , :advocate_id  => params[:hid] ) unless memorize
    end

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace( "store_advo_#{params[:hid]}" , link_to_remote( 'Anwalt nicht mehr merken',  {:url => url_for( remove_client_account_store_path( params[:id] , :hid => params[:hid] ) )}, {:id => "store_advo_#{params[:hid]}"}) )
        end
      end
    end
  end
  
  def remove
    memorize = current_user.person.memorizes.find_by_advocate_id( params[:hid] )
    memorize.destroy if memorize
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace( "store_advo_#{params[:hid]}" , link_to_remote( 'Anwalt merken',  {:url => url_for( add_client_account_store_path( params[:id] , :hid => params[:hid] ) )}, {:id => "store_advo_#{params[:hid]}"}) )
        end
      end
    end
    

  end
  
end