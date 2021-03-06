class GuidesController < ApplicationController
  before_action :set_guide, only: [:show, :edit, :update, :destroy, :toggle_status]
  before_action :set_sidebar_topics, except: [:update, :create, :destroy, :toggle_status]
  layout("guide")
  access all: [:show, :index], user: {except: [:destroy, :new, :create, :update, :edit, :toggle_status]}, site_admin: :all

  # GET /guides
  # GET /guides.json
  def index
    if logged_in?(:site_admin)
      @guides = Guide.recent.page(params[:page]).per(5)
    else
      @guides = Guide.published.recent.page(params[:page]).per(5)
    end
    @page_title = "My Portfolio Guide"
  end

  # GET /guides/1
  # GET /guides/1.json
  def show
    if logged_in?(:site_admin) || @guide.published?
      @guide = Guide.includes(:comments).friendly.find(params[:id])
      @comment = Comment.new

      @page_title = @guide.title
      @seo_keywords = @guide.content
    else
      redirect_to guides_path, notice: "You are not authorized to access this page"
    end
  end

  # GET /guides/new
  def new
    @guide = Guide.new
  end

  # GET /guides/1/edit
  def edit
  end

  # POST /guides
  # POST /guides.json
  def create
    @guide = Guide.new(guide_params)

    respond_to do |format|
      if @guide.save
        format.html { redirect_to @guide, notice: 'Guide was successfully created.' }
        format.json { render :show, status: :created, location: @guide }
      else
        format.html { render :new }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /guides/1
  # PATCH/PUT /guides/1.json
  def update
    respond_to do |format|
      if @guide.update(guide_params)
        format.html { redirect_to @guide, notice: 'Guide was successfully updated.' }
        format.json { render :show, status: :ok, location: @guide }
      else
        format.html { render :edit }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guides/1
  # DELETE /guides/1.json
  def destroy
    @guide.destroy
    respond_to do |format|
      format.html { redirect_to guides_url, notice: 'Guide was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def toggle_status

    if @guide.draft?
      @guide.published!
    elsif @guide.published?
      @guide.draft!
    end
      
    redirect_to guides_url, notice: 'Post status has been updated.'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guide
      @guide = Guide.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def guide_params
      params.require(:guide).permit(:title, :content, :topic_id, :status)
    end

    def set_sidebar_topics
      @side_bar_topics = Topic.with_guides
    end
end
