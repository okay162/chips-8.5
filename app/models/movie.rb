class Movie < ActiveRecord::Base
    def self.all_ratings
      ['G', 'PG', 'PG-13', 'R']
    end
    
    def self.with_ratings(ratings, sort_by)
      if ratings.nil?
        all.order sort_by
      else
        where(rating: ratings.map(&:upcase)).order sort_by
      end
    end
  
    def self.find_in_tmdb(search_terms)
      query = "https://api.themoviedb.org/3/search/movie?api_key=c4ce88d789ecd2caad42a13cba8642d5&query=" + search_terms[:title]
      if search_terms["release_year"] and !search_terms["release_year"].empty? then
        query += "&year=" + search_terms["release_year"]
      end
      if search_terms["language"] and !search_terms["language"].empty? then
        query += "&language=" + search_terms["language"]
      end
      res = JSON.parse(Faraday.get(URI.escape(query)).body)
      if res["results"] then
        movies = []
        res["results"].each do |m|
          if !Movie.exists?(title: m["title"]) then
            movie1 = Movie.new(title: m["title"], release_date: m["release_date"], description: m["overview"], rating: "R")
            movies.append(movie1)
          end
        end
        return movies
      end
      return []
    end
  
end
  