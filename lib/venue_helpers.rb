module VenueHelpers
  DAY_DO = []
  DAY_SEE = []
  EVENING_DO = []
  EVENING_SEE = []
  NIGHT_DO = []
  NIGHT_SEE = []
  BONUS = []
  INDOOR = []
  DAY_EAT = []
  EVENING_EAT = []
  
  def VenueHelpers.get_day_eat_query_options
    category = Array.new VenueHelpers::DAY_EAT
    return {:category_filter => category}
  end

  def VenueHelpers.get_evening_eat_query_options
    category = Array.new VenueHelpers::EVENING_EAT
    return {:category_filter => category}
  end
  
  def VenueHelpers.get_day_do_query_options (p_indoor=false)
    category = Array.new VenueHelpers::DAY_DO
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end
  
  def VenueHelpers.get_day_see_query_options (p_indoor=false)
    category = Array.new VenueHelpers::DAY_SEE
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end
  
  def VenueHelpers.get_evening_do_query_options (p_indoor=false)
    category = Array.new VenueHelpers::EVENING_DO
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end
  
  def VenueHelpers.get_evening_see_query_options (p_indoor=false)
    category = Array.new VenueHelpers::EVENING_SEE
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end

  def VenueHelpers.get_night_do_query_options (p_indoor=false)
    category = Array.new VenueHelpers::NIGHT_DO
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end
  
  def VenueHelpers.get_night_see_query_options (p_indoor=false)
    category = Array.new VenueHelpers::NIGHT_SEE
    if (p_indoor == 'indoor')
      category.select! { |elem| 
        VenueHelpers::INDOOR.include? elem
      }
    elsif (p_indoor == 'outdoor')
      category.select! { |elem| 
        not VenueHelpers::INDOOR.include? elem
      }
    end
    return {:category_filter => category}
  end
  
  #Rails.logger.debug "Filling Yelp Cat Data"
  #Load Yelp Category Data
  data_dir = File.dirname(__FILE__).to_s + "/.."
  
  Dir.entries(data_dir + "/category_data/yelp").select { |file_name| file_name.include? (".txt") }.each do |file_name|
    if (file_name[0...-4] == "day_do")
      the_file = File.new(data_dir + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::DAY_DO << elem
        end
      end
    elsif (file_name[0...-4] == "day_see")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::DAY_SEE << elem
        end
      end
    elsif (file_name[0...-4] == "evening_do")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::EVENING_DO << elem
        end
      end
    elsif (file_name[0...-4] == "evening_see")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::EVENING_SEE << elem
        end
      end
    elsif (file_name[0...-4] == "night_do")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::NIGHT_DO << elem
        end
      end
    elsif (file_name[0...-4] == "night_see")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::NIGHT_SEE << elem
        end
      end
    elsif (file_name[0...-4] == "bonus")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::BONUS << elem
        end
      end
    elsif (file_name[0...-4] == "indoor")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::INDOOR << elem
        end
      end
    elsif (file_name[0...-4] == "evening_restaurants")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::EVENING_EAT << elem
        end
      end
    elsif (file_name[0...-4] == "day_restaurants")
      the_file = File.new(data_dir.to_s + "/category_data/yelp/" + file_name,'r')
      while (line = the_file.gets)
        line.split("~").each do |elem|
          VenueHelpers::DAY_EAT << elem
        end
      end
    end
  end

end