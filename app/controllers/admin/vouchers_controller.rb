class Admin::VouchersController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :voucher do |config|
    #--- columns
    standard_columns = [
      :id,
      :consignor_id,
      :consignee_id,
      :code,
      :uuid,
      :batch,
      :created_at,
      :updated_at,
      :expires_at,
      :redeemed_at,
      :type,
      :amount,
      :multiple_redeemable
    ]
    crud_columns = [
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:batch, :code, :amount, :multiple_redeemable, :created_at, :expires_at, :redeemed_at]
    
    config.list.per_page = 100
    config.list.sorting = [{:batch => :desc}]
    
    config.actions.exclude :create, :show, :update
    config.nested.add_link('Einlösungen', [:voucher_redemptions], :page => false, :inline => true, :position => :after)
    
    class CreateVouchersConfirm < DHTMLConfirm

      def onclick_handler(controller, link_id)
        "Modalbox.show($('#{link_id}').href, {title: $('#{link_id}').innerHTML, width: 400});return false;"
      end

    end

    config.action_links.add :create_vouchers, :label => 'Neu anlegen', 
      :page => false, :inline => true, :position => :top, :action => "show_create_vouchers",
        :dhtml_confirm => CreateVouchersConfirm.new
    
    config.action_links.add :export, :label => 'Exportieren', :type => :table, 
      :action => 'export', :inline => false, :position => false
  end 
  
  def show_create_vouchers
    @promotion_voucher_booking = PromotionVoucherBooking.new
    render :layout => false
  end
  
  def create_vouchers
    @promotion_voucher_booking = PromotionVoucherBooking.new({}.merge(params[:promotion_voucher_booking].symbolize_keys || {}))
    if @promotion_voucher_booking.valid?
      @promotion_voucher_booking.create!
      respond_to do |format|
        format.js {
          render :update do |page|            
            page.redirect_to admin_vouchers_path
          end
        }
        format.html {
          redirect_to admin_vouchers_path
        }
      end
      return
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          render :update do |page|            
            page.replace dom_class(Voucher, :show_create_vouchers), :partial => "show_create_vouchers"
            page << "Modalbox.resizeToContent()"
          end
        }
      end
    end
  end

  def export
    @records = Voucher.all
    
    file_name = "#{RAILS_ROOT}/tmp/vouchers_#{Time.now.to_i}.csv"
    stream = File.open(file_name, 'wb')

    CSV::Writer.generate(stream) do |csv|
      # header
      csv << [PromotionContactVoucher.human_attribute_name(:batch),
        PromotionContactVoucher.human_attribute_name(:code),
        PromotionContactVoucher.human_attribute_name(:amount),
        PromotionContactVoucher.human_attribute_name(:multiple_redeemable),
        PromotionContactVoucher.human_attribute_name(:created_at),
        PromotionContactVoucher.human_attribute_name(:expires_at),
        PromotionContactVoucher.human_attribute_name(:redeemed_at)]
      
      # body
      @records.each do |voucher|
        row = []
        row << voucher.batch.to_s
        row << voucher.code
        row << voucher.amount.to_s
        row << (voucher.multiple_redeemable ? "Ja" : "Nein")
        row << (voucher.created_at ? I18n.l(voucher.created_at) : "-")
        row << (voucher.expires_at ? I18n.l(voucher.expires_at) : "-")
        row << (voucher.redeemed_at ? I18n.l(voucher.redeemed_at) : "-")
        csv << row
      end
      
    end
    stream.close
    send_file file_name, :type => 'application/excel', :disposition => 'attachment',
      :encoding => "utf8"
  end

end
