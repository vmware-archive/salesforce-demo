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
    options = {
        :start_container => '<ul>',
        :end_container=> '</ul>',
        :start_tag => '<li>',
        :end_tag => '</li>',
        :start_key => '',
        :start_value => "",
        :end_elem => ''
    }
    hashie_to_html hashie, options
  end

  def hashie_to_grid hashie
    options = {
        :start_container => '',
        :end_container=> '',
        :start_tag => "<div class='grid_10 prefix_1' >",
        :end_tag => "</div>",
        :start_key => "<div class='grid_3 alpha' ><span>",
        :start_value => "<div class='grid_7 omega' ><span>",
        :end_elem => "</span></div>"
    }
    hashie_to_html hashie, options
  end

  def hashie_to_html hashie, options
    output = options[:start_container]
    i = 0
    hashie.keys.each do |key|
      value = hashie[key]
      unless value.nil?
        if (value.respond_to? :keys)
          value = hashie_to_ul value
        elsif (value.class == Array)
          value = array_to_ul value
        elsif (value.class == String)
          if (value =~ /^http.+\.(jpg|jpeg|png|gif)/)
            value = "<img src='#{value}' />"
          elsif (value =~ /^http/)
            value = "<a href='#{value}'>#{value}</a>"

          end
        end

        key = key.split(/([[:upper:]][[:lower:]]*)/).delete_if(&:empty?).join("_")
        key = key.split('_').join(' ').capitalize
        output += "#{options[:start_tag]}#{options[:start_key]}#{key}:#{options[:end_elem]}"
        output +=" #{options[:start_value]}#{value}#{options[:end_elem]}#{options[:end_tag]}\n"
      end
      i += 1
    end
    output += "#{options[:end_container]}\n"
    return output
  end
end