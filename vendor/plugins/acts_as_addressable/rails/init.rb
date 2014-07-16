require 'acts_as_addressable'

ActiveRecord::Base.send(:include, Acts::Addressable)
RAILS_DEFAULT_LOGGER.info "** acts_as_addressable: plugin initialized properly."