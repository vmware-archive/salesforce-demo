helpers do
  def array_to_ul array
    output = '<ul>'
    array.each do |value|
      if (value.respond_to? :keys)
        value = hashie_to_ul value
      elsif (value.class == Array)
        value = array_to_ul value
      end
      output += "<li>#{value}</li>"
    end
    output += '</ul>'
    return output
  end

  def hashie_to_ul hashie
    output = '<ul>'
    hashie.keys.each do |key|
      value = hashie[key]
      unless value.nil?
        if (value.respond_to? :keys)
          value = hashie_to_ul value
        elsif (value.class == Array)
          value = array_to_ul value
        end
        output += "<li><strong>#{key}</strong>: #{value}</li>"
      end
    end
    output += '</ul>'
    return output
  end
end