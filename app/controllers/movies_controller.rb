class MoviesController < ApplicationController
    before_action :force_index_redirect, only: [:index]
  
    def search_tmdb
      if !params then
        render 'search_tmdb'
        return
      end
      if !params["title"] or params["title"].empty? then
        flash[:warning] = "Please fill in all required fields!"
        render 'search_tmdb'
        flash.clear
        return
      end
      @movies = Movie.find_in_tmdb(params)
        puts @movies
      if @movies.empty? then
        flash[:info] = "No movies found with given parameters!"
        @movies = nil
      end
      render 'search_tmdb'
      flash.clear
    end
        
    def add_movie
      if !params then
        redirect_to search_tmdb_path
      end
      @movie = Movie.create(title: params["title"], rating: params["rating"], release_date: params["release_date"])
      flash[:success] = "#{@movie.title} was successfully created."
      redirect_to search_tmdb_path
    end
    
    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @all_ratings = Movie.all_ratings
      @movies = Movie.with_ratings(ratings_list, sort_by)
      @ratings_to_show_hash = ratings_hash
      @sort_by = sort_by
      # remember the correct settings for next time
      session['ratings'] = ratings_list
      session['sort_by'] = @sort_by
    end
    
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
    
    private
  
    def force_index_redirect
      if !params.key?(:ratings) || !params.key?(:sort_by)
        flash.keep
        url = movies_path(sort_by: sort_by, ratings: ratings_hash)
        redirect_to url
      end
    end
  
    def ratings_list
      params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
    end
  
    def ratings_hash
      Hash[ratings_list.collect { |item| [item, "1"] }]
    end
  
    def sort_by
      params[:sort_by] || session[:sort_by] || 'id'
    end
      
      
  end