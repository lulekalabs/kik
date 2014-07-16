#
# Copyright (c) 2007-2011 Juergen Fesslmeier
# 
# Permission is hereby granted, to kann-ich-klagen.de, for this software and associated 
# documentation files (the "Software"). The Software is restricted, including the rights 
# to copy, modify, merge, publish, distribute, sublicense, and/or sell or resell copies
# of the Software, and is not permitted to persons to whom the Software is not furnished 
# to do so.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
module Merchant #:nodoc:
  module Sidekick #:nodoc:
    module Buyer #:nodoc:

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_buyer
          include Merchant::Sidekick::Buyer::InstanceMethods
          class_eval do
            has_many :orders, :as => :buyer, :dependent => :destroy
            has_many :invoices, :as => :buyer, :dependent => :destroy
            has_many :purchase_orders, :as => :buyer
            has_many :purchase_invoices, :as => :buyer
          end
        end
      end
      
      module InstanceMethods
        
        # like purchase but forces the seller parameter, instead of 
        # taking it as a :seller option
        def purchase_from(seller, *arguments)
          purchase(arguments, :seller => seller)
        end
        
        # purchase creates a purchase order based on
        # the given sellables, e.g. product, or basically
        # anything that has a price attribute.
        #
        # e.g.
        #
        #   buyer.purchase(product, :seller => seller)
        #
        def purchase(*arguments)
          sellables = []
          options = default_purchase_options

          # distinguish between options and attributes
          arguments = arguments.flatten
          arguments.each do |argument|
            case argument.class.name
            when 'Hash'
              options.merge! argument
            else
              sellables << argument
            end
          end
          raise ArgumentError.new("No sellable (e.g. product) model provided") if sellables.empty?
          raise ArgumentError.new("Sellable models must have a :price") unless sellables.all? {|sellable| sellable.respond_to? :price}
          
          returning self.purchase_orders.build do |po|
            po.buyer = self
            po.seller = options[:seller]
            po.build_addresses
            sellables.each do |sellable|
              if sellable && sellable.respond_to?(:before_add_to_order)
                sellable.send(:before_add_to_order, self)
                sellable.reload unless sellable.new_record?
              end
              li = LineItem.new(:sellable => sellable, :order => po)
              po.line_items.push(li)
              sellable.send(:after_add_to_order, self) if sellable && sellable.respond_to?(:after_add_to_order)
            end
          end
        end
        
        protected
        
        # override in model, e.g. :seller => @person
        def default_purchase_options
          {}
        end
        
      end
    end
  end
end