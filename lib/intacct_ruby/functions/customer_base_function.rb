require 'builder'

require 'intacct_ruby/helpers/contacts_helper'
require 'intacct_ruby/functions/base_function'

module IntacctRuby
  module Functions
    # the parent for all customer-related functions. Includes methods that
    # cut down on duplicate code
    class CustomerBaseFunction < BaseFunction
      include ContactsHelper

      def initialize(controlid, attrs = {})
        @attrs = attrs

        super(controlid)
      end

      private

      def customer_params
        xml = Builder::XmlMarkup.new

        xml.name full_name(@attrs)
        xml.status @attrs[:status]
        xml.contactinfo do
          xml << contact_params(@attrs)
        end

        xml.target!
      end
    end
  end
end
