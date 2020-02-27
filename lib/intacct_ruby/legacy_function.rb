module IntacctRuby
  class LegacyFunction < Function

    def to_xml
      xml = Builder::XmlMarkup.new
      # Use the parameters to create attributes
      attributes = @parameters.select { |k,v| /^\*/.match(k) }
      attributes = attributes.inject({}) do |hash, (k, v)|
        hash[k.to_s.gsub(/^\*/, '')] = v
        hash
      end unless attributes.empty?

      # Find the duplicate keys
      duplicate = @parameters.deep_dup
      omitted_keys = []

      duplicate.each do |key, value|
        omitted_keys << value.select { |k,v| /^\*/.match(k) } if value.is_a? Hash
        if value.is_a? Array
          value.each do |val|
            if val.is_a? Hash
              omitted_keys << val.select { |k,v| /^\*/.match(k) }
              val.each_value do |v|
                omitted_keys << v.select { |k,v| /^\*/.match(k) } if v.is_a? Hash
              end
            end
          end
        end
      end
      omitted_keys = omitted_keys.reduce({}, :merge).collect { |k,v| k.to_s.gsub(/^\*/, '').to_sym }

      #  Clean the parameters before sending off to API
      @parameters.each do |key, value|
        value.reject! { |k,v| /^\*/.match(k) || omitted_keys.include?(k)} if value.is_a? Hash
        if value.is_a? Array
          value.each do |val|
            if val.is_a? Hash
              val.reject! { |k,v| /^\*/.match(k) || omitted_keys.include?(k)}
              val.each_value do |v|
                v.reject! { |k,v| /^\*/.match(k) || omitted_keys.include?(k)} if v.is_a? Hash
              end
            end
          end
        end
      end

      # Build the XML
      xml.function controlid: controlid do
        xml.tag! @object_type, attributes do
          xml << parameter_xml(@parameters)
        end
      end

      xml.target!
    end

  end
end
