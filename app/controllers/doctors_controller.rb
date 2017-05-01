

class DoctorsController < ApplicationController


  before_action :set_doctor, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @search = Search.new(search_params)
    @reviews = Review.all
    @doctors = Doctor.all
    @review = Review.new

    if params[:search] && params[:search][:name].present?
      @name = params[:search][:name]
      @doctors = @doctors.where("name ILIKE  ?", "%#{@name}%")
    end

    if params[:search] && params[:search][:rating].present?
      @rating = params[:search][:rating]
      @doctors = @doctors.select {|d| d.reviews.count.positive? && d.reviews.average(:rating) >= @rating.to_i }
    end

    if params[:search] && params[:search][:specialty].present?
      @specialty_params = params[:search][:specialty]
      @doctors = @doctors.joins(:specialties).where(specialties: { name:  params[:search][:specialty]})
    end

    @doctors = Kaminari.paginate_array(@doctors) if @doctors.class == Array
    @doctors = @doctors.page(params[:page]).per(10)
    # @doctors
    # .select('movie_id, movie_name, avg(reviews.rating_out_of_ten)')
    # .join(:reviews)
    # .group('movie_id, movie_name')
    # .order('avg(reviews.rating_out_of_ten) desc')
    #@doctors = @doctors.order(@doctors.each {|d| d.reviews.average(:rating)})
    # @doctors
    #   .joins(:reviews)
    #   .order("avg(reviews.rating)")

      # @doctors = @doctors.order(@doctors.each {|d| d.reviews.average(:rating)})

      @doctors

  end






  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      redirect_to doctor_path(@doctor)
    else
      render :new
    end
  end

  def show
    @doctor = Doctor.find(params[:id])
    @review = Review.new

  end

  def edit
    #@doctor = Doctor.find(params[:id])
  end

  def update
    @doctor.update(doctor_params)
    redirect_to doctor_path(@doctor)

  end

  def destroy
    @doctor = Doctor.find(params[:id])
    @doctor.destroy
    redirect_to doctors_path
  end


private


  def doctor_params
    params.require(:doctor).permit(:photo, :photo_cache, :name, :street_name, :city_name, :phone, :description, :activity, :crm, :insurance, :website)
  end

  def search_params
    params.require(:search).permit(:first_name) if params[:search]
  end

  def set_doctor
    @doctor = Doctor.find(params[:id])
  end

end




