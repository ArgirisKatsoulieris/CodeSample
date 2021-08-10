class FireEventsController < ApplicationController
  #before_action :cleanup_pagination_params
  #load_and_authorize_resource
  #before_action :authenticate_user!
  #before_action :set_post, only: [:show, :edit, :update, :destroy]

  $call_from_show = false
  $latest_events = nil

  def show
    $call_from_show = true
    querydatabase
    $call_from_show = false
  end

  def querydatabase
    @events = []
    id_array = params[:idList].split(',')
    id_array.each { |x| 
      @fire_event = FireEvent.find(x)
      @events << @fire_event
    }
    if $call_from_show == false
      if params[:dateFrom].present? && params[:dateTo].present?
        @events = @events.where('sdate' => {'$gte' => params[:dateFrom]},'edate' => {'$lte' => params[:dateTo]})
      else
        if @events == []
          @events = FireEvent.all
        end
      end
      if params[:date].present?
        #puts params[:date].to_s.scan(/\d+/).map(&:to_i)
        dateForSearch = params[:date].to_s.scan(/\d+/).map(&:to_i).to_s
        if dateForSearch != "[]"
          dateForSearch[0] = ''
          dateForSearch[-1] = ''
          dateForSearchStart = dateForSearch + "-01-01"
          dateForSearchEnd = dateForSearch + "-31-01"
          @events = FireEvent.where('sdate' => {'$gte' => dateForSearchStart},'edate' => {'$lte' => dateForSearchEnd})
          #puts dateForSearchEnd
        end
      end
      if params[:acresFrom].present? && params[:acresTo].present?
        @events = @events.where('tsize' => {'$gte':params[:acresFrom],'$lte':params[:acresTo]})
      end
      if params[:durationFrom].present? && params[:durationTo].present?
        before = params[:durationFrom].to_f
        theEnd = params[:durationTo].to_f 
        @events = @events.where('duration' => {'$gte' => before,'$lte' => theEnd})
      end
      if params[:periferiaki_enotita_select].present?
        @events = @events.where(periferiaki_enotita: params[:periferiaki_enotita_select])
      end
      if params[:aitia_select].present?
        @events = @events.where(aitia_pirkagias: params[:aitia_select])
      end
      if params[:ipiresia_select].present?
        @events = @events.where(pirosvestiki_ipiresia: params[:ipiresia_select])
      end
      $latest_events = @events
    else
      @events = $latest_events
    end
    render 'querydatabase'
  end

  def index
    @events = FireEvent.all
  end

  def new
    @fire_event = FireEvent.new
  end

  def create
    @fire_event = FireEvent.new(fire_events_params)
    #print(fire_events_params)
    @fire_event.location = [ params["fire_event"]["location"][0].to_f, params["fire_event"]["location"][1].to_f ]
    if @fire_event.save
     redirect_to root_path, notice: "The fire event has been created !" and return
    end
    render 'new'
  end

  def edit
    @events=FireEvent.all
    print("********edit-BEFORE********")
    @fire_event = FireEvent.find(params[:id])
    #print(fire_events_params)
    #print(@fire_event.location)
    print("********edit-AFTER********")
    #@fire_event.save
    
  end

  def update
    print("+++++++++++ UPDATE START +++++++++++")
    @fire_event = FireEvent.find(params[:id])
    #raise params.inspect
    if @fire_event.update_attributes( fire_events_params )
      if @fire_event.update_attribute( :location, params["fire_event"]["location"] )
        print("++++++++ UPDATE END ++++++++++")
        redirect_to root_path, notice: "update" and return
      end
    end
  end

  def destroy
    @fire_event = FireEvent.find(params[:id])
    @fire_event.destroy

    redirect_to events_path, notice: "Destroy" and return
  end

  def fire_events_params
    #@fire_event = FireEvent.find(params[:_id])
    #print("$$$$$$$$$ FIRE EVENT PRINT START $$$$$$$$$$ \n")
    #puts @fire_event.to_yaml
    params.require(:fire_event).permit(:_id, :alsi, :dasarxeio, :dasi, :dasiki_ektasi, :edate, :georgikes_ektaseis, :kalamia_valtoi, :location, :latitude, :longitude, :sdate, :skoupidotopoi, :stime, :etime, :topiki_koinotita, :tsize, :upoleimmata_kalliergiwn, :xortkes_ektaseis, :duration, :dimos, :periferiaki_enotita, :arithmos_pirosvestikwn_oximatwn, :arithmos_pirosvestwn, :arithmos_ipallilwn_pezoporwn_tmimatwn, :arithmos_aeroplanwn, :arithmos_elikopterwn, :perimetros_kamenis_ektasis, :pirosvestiki_ipiresia, :aitia_pirkagias )
    #print("$$$$$$$$$ FIRE EVENT PRINT END $$$$$$$$$$ \n")
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_fire
    @fire = FireEvent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def fire_params
    params.require(:fire_event).permit(:alsi, :dasarxeio, :dasi, :dasiki_ektasi, :edate, :georgikes_ektaseis, :kalamia_valtoi, :location, :latitude, :longitude, :sdate, :skoupidotopoi, :stime, :etime, :topiki_koinotita, :tsize, :upoleimmata_kalliergiwn, :xortkes_ektaseis, :duration, :dimos, :periferiaki_enotita, :arithmos_pirosvestikwn_oximatwn, :arithmos_pirosvestwn, :arithmos_ipallilwn_pezoporwn_tmimatwn, :arithmos_aeroplanwn, :arithmos_elikopterwn, :perimetros_kamenis_ektasis, :pirosvestiki_ipiresia, :aitia_pirkagias)
  end
  
  def cleanup_pagination_params
    #puts("@@@@@@@@@@@@@ cleanup_pagination_params @@@@@@@@@@@@@@@@@")
    params[:dasi].to_i
    params[:alsi].to_i
  end

end

