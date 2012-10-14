module SummerResidents
  class BungalowsController < SummerResidentsController
    # GET /bungalows
    # GET /bungalows.json
    def index
      @bungalows = Bungalow.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @bungalows }
      end
    end
  
    # GET /bungalows/1
    # GET /bungalows/1.json
    def show
      @bungalow = Bungalow.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @bungalow }
      end
    end
  
    # GET /bungalows/new
    # GET /bungalows/new.json
    def new
      @bungalow = Bungalow.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @bungalow }
      end
    end
  
    # GET /bungalows/1/edit
    def edit
      @bungalow = Bungalow.find(params[:id])
    end
  
    # POST /bungalows
    # POST /bungalows.json
    def create
      @bungalow = Bungalow.new(params[:bungalow])
  
      respond_to do |format|
        if @bungalow.save
          format.html { redirect_to @bungalow, :notice => 'Bungalow was successfully created.' }
          format.json { render :json => @bungalow, :status => :created, :location => @bungalow }
        else
          format.html { render :action => "new" }
          format.json { render :json => @bungalow.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /bungalows/1
    # PUT /bungalows/1.json
    def update
      @bungalow = Bungalow.find(params[:id])
  
      respond_to do |format|
        if @bungalow.update_attributes(params[:bungalow])
          format.html { redirect_to @bungalow, :notice => 'Bungalow was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @bungalow.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /bungalows/1
    # DELETE /bungalows/1.json
    def destroy
      @bungalow = Bungalow.find(params[:id])
      @bungalow.destroy
  
      respond_to do |format|
        format.html { redirect_to bungalows_url }
        format.json { head :no_content }
      end
    end
  end
end
