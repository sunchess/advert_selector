require_dependency "advert_selector/application_controller"

module AdvertSelector
  class BannersController < ApplicationController
    # GET /banners
    # GET /banners.json
    def index
      @banners = Banner.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @banners }
      end
    end

    # GET /banners/1
    # GET /banners/1.json
    def show
      redirect_to edit_banner_url(params[:id])

      #@banner = Banner.find(params[:id])
      #
      #respond_to do |format|
      #  format.html # show.html.erb
      #  format.json { render :json => @banner }
      #end
    end

    # GET /banners/new
    # GET /banners/new.json
    def new
      if params[:duplicate_id] && banner_dup = Banner.find(params[:duplicate_id])
        @banner = banner_dup.dup
        @banner.name += " (copy)"
        @banner.confirmed = false

        banner_dup.helper_items.each do |hi|
          @banner.helper_items << hi.dup
        end

      else
        @banner = Banner.new
        @banner.start_time = Time.now.at_midnight
        @banner.end_time = 1.week.from_now.end_of_day
      end

      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @banner }
      end
    end

    # GET /banners/1/edit
    def edit
      @banner = Banner.find(params[:id])
    end

    # POST /banners
    # POST /banners.json
    def create
      @banner = Banner.new(banner_params)

      respond_to do |format|
        if @banner.save
          format.html { redirect_to @banner, :notice => 'Banner was successfully created.' }
          format.json { render :json => @banner, :status => :created, :location => @banner }
        else
          format.html { render :action => "new" }
          format.json { render :json => @banner.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /banners/1
    # PUT /banners/1.json
    def update
      @banner = Banner.find(params[:id])

      respond_to do |format|
        if @banner.update(banner_params)
          format.html { redirect_to @banner, :notice => 'Banner was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @banner.errors, :status => :unprocessable_entity }
        end
      end
    end


    def update_running_view_count
      @banner = Banner.find(params[:id])
      if !(@count = params['banner']["running_view_count"]).blank?
        @count = @count.to_i
        Banner.where(:id => @banner.id).update_all(:running_view_count => @count)
        50.times do
          # We are trying to make sure that no other process will overwrite this value
          Rails.cache.write(@banner.cache_key, @count, :expires_in => 2.weeks)
          sleep(0.02)
        end
        Banner.where(:id => @banner.id).update_all(:running_view_count => @count)
        #@banner[:running_view_count] = @count
        #@banner.save
      end

      redirect_to @banner
    end

    # DELETE /banners/1
    # DELETE /banners/1.json
    def destroy
      @banner = Banner.find(params[:id])
      @banner.destroy

      respond_to do |format|
        format.html { redirect_to banners_url }
        format.json { head :no_content }
      end
    end

    private
    def banner_params
      params
        .require(:banner)
        .permit(
          :comment, :end_time, :frequency, :name, :placement_id, :start_time, :target_view_count, :priority, :confirmed, :fast_mode,
          :helper_items_attributes => [:id, :name, :content_for, :position, :content, :file]
        )
    end
  end
end
