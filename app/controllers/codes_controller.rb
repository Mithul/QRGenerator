class CodesController < ApplicationController
  before_action :set_code, only: [:show, :edit, :update, :destroy]

  # GET /codes
  # GET /codes.json

  def qrgen
  end

  def qrpage
    # require ‘RMagick’
    # include Magick
    #  sudo aptitude install wkhtmltopdf
    @qr = []
    @codes = []
    list = params[:list]
    start= list[:start]
    ending=list[:end]
    puts  start.to_i-ending.to_i
    if start.to_i-ending.to_i != -15
      redirect_to :back, :alert => "Range must be 16."
    end
    list = (start.to_i..ending.to_i).to_a
    puts list
    list.each do |i|
      str = 'KQ16' + '0'*(4-i.to_s.length) + i.to_s
      # qr = RQRCode::QRCode.new( str, :size => 4, :level => :h )
      qr_code_img = RQRCode::QRCode.new( str, :size => 3, :level => :h ).to_img

      check= Code.find_by_qr(str)

      if check and params[:list][:check] == "1"
        redirect_to :back, :alert => 'QR code for '+str+' exists'
        return
      end

      code = Code.new
      code.qr=str
      code.update_attribute :qrcode, qr_code_img.to_string
      code.save

  

      @codes.append(code)
      # @qr.append(qr)
    end
     respond_to do |format|
      format.html { render layout: 'qr' }
      format.pdf do
        render :pdf => 'file_name',
        :page_size => 'A3'
    end
  end

  end

  def index
    @codes = Code.all
  end

  # GET /codes/1
  # GET /codes/1.json
  def show
  end

  # GET /codes/new
  def new
    @code = Code.new
  end

  # GET /codes/1/edit
  def edit
  end

  # POST /codes
  # POST /codes.json
  def create
    @code = Code.new(code_params)

    respond_to do |format|
      if @code.save
        format.html { redirect_to @code, notice: 'Code was successfully created.' }
        format.json { render :show, status: :created, location: @code }
      else
        format.html { render :new }
        format.json { render json: @code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /codes/1
  # PATCH/PUT /codes/1.json
  def update
    respond_to do |format|
      if @code.update(code_params)
        format.html { redirect_to @code, notice: 'Code was successfully updated.' }
        format.json { render :show, status: :ok, location: @code }
      else
        format.html { render :edit }
        format.json { render json: @code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes/1
  # DELETE /codes/1.json
  def destroy
    @code.destroy
    respond_to do |format|
      format.html { redirect_to codes_url, notice: 'Code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code
      @code = Code.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_params
      params.require(:code).permit(:qr,:start,:end)
    end
end
