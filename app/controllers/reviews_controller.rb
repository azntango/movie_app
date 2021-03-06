require 'net/http'

class ReviewsController < ApplicationController
  def new
  	@review = Review.new
  end

  def create
  	review = Review.new(review_params)

  	movie = Movie.find_by_nk_movie_id(review.movie_id)
  	if !movie
  		#pull the movie information and store it locally
  		response = Net::HTTP.get(URI.parse('https://api.themoviedb.org/3/movie/' + review.movie_id.to_s  + '?api_key=4cd9d92801f92d8885c5df0bcff5b0e6&language=en-US'))
  		json = JSON.parse(response)

      if !json['status_code'] #no status code in json means success
    		genre = json['genres'][0]['name']
    		title = json['original_title']
    		release_date = json['release_date']
  		  movie = Movie.new(release_date: release_date, genre: genre, title: title, nk_movie_id: review.movie_id)
      else
        flash[:alert] = "Unable to load movie details from themoviedb.org. Please try again later."
        redirect_to root_path
        return false
      end

  		if not movie.save
  			flash[:alert] = "Unable to load movie details from themoviedb.org. Please try again later."
        redirect_to root_path
        return false
  		end

  	end

  	review.movie_id = movie.id #reassign to the primary key of the movie
  	if review.save
  		flash[:notice] = "Successfully made a review"
  		redirect_to root_path
      return false
  	else
      flash[:alert] = "Invalid email format"
  		redirect_to '/reviews/new/?id=' + movie.nk_movie_id.to_s + '&title=' + movie.title
      return false
	  end
  end

  def index
  	@reviewList = []
  	reviews = Review.all.order(created_at: :desc)
	  reviews.each do |review|
		  #find movie title associated to review
		  title = Movie.find_by_id(review.movie_id).title
		  @reviewList << [review, title]
	  end
  end

  private
  def review_params
  	params.require(:review).permit(:first_name, :last_name, :email, :rating, :movie_id, :comment)
  end

end
