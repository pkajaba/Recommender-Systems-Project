class ContentBasedStrategy
  def initialize

  end

  def recommend_next(user)
    #have some groups of jokes dependant on length
    case user.rating.length
      when 0..5
        #daky shuffle na 5 skupin vtipov a vyber z tej ktora este nebola
      else
        #realne odporucaj podla hodnotenia jednotlivich v skupine
    end

  end

end