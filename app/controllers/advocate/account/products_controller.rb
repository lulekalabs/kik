# Shows the product catalog to pick from
class Advocate::Account::ProductsController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- actions
  
  def index
  end
  
  def create
    @product = Product.find_by_sku(params[:product][:sku])
    
    if @product.blank?
      flash[:error] = "Das ausgewählte Produkt konnte nicht gefunden werden."
      redirect_to advocate_account_products_path
    else
      if true
        @cart ||= Cart.new("EUR")
        @cart.add(@product)
        store_cart(@cart)
        redirect_to new_advocate_account_order_path
      else
        flash[:error] = "#{@product.name} kann nicht gekauft werden."
        redirect_to advocate_account_products_path
      end
    end
  end
  
  
end
