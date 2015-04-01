class CodesController < ApplicationController
  before_action :set_code, only: [:show, :edit, :update, :destroy]

  # GET /codes
  # GET /codes.json

  def qrgen
  end

  def qrscan
  end

  def pdfscanner
    File.open("tmp/qr.pdf",'wb') do |f|
      f.write params[:list][:file].read
    end

    require 'RMagick'
    pdf = Magick::ImageList.new("tmp/qr.pdf")
    pdf.write("tmp/qr.jpg")

    @result = true

    fname = "tmp/qr.jpg"
    cols = 10
    rows = 16
    img = Magick::Image.read(fname)[0]

    width = (img.columns)/cols-34
    height = (img.columns)/cols-34

    # create a new empty image to composite the tiles upon:
    new_img = []

    row = 0
    col = 0
    i=0
    err = 0

    # tiles will be an array of Image objects
    tiles = (cols * rows).times.inject([]) do |arr, idx|
      # i++
      col = idx%cols
      row = idx/cols
      z=  2*row
      x=col
      l = 3*(row/7)
      w = 5*(row/13)
      arr << Magick::Image.constitute(width, height, 'RGB',
              img.dispatch( 54+(idx%cols) * width + col*26-x, 
                            38+idx/cols * height+row*18-z-l+w,
                            width, height, 'RGB' )) 
      # new_img.write("#{FNAME}-shuffle.jpg")
    end

    # tiles.shuffle.each_with_index do |tile, idx|
    #   z=Magick::Image.new(img.columns/cols, img.rows/rows)
    #   z.composite!( tile, idx%cols * height, 
    #                   idx/cols * height,
    #                   Magick::OverCompositeOp)
    #   z.write("tmp/#{idx}-shuffle.jpg")
    # end
    i=0
    result = ""
    n = []
    tiles.each_with_index do |tile, idx|
      oldres = result
      z=Magick::Image.new(width, height)
      z.composite!( tile,0, 
                      0,
                      Magick::OverCompositeOp)
      z.write("tmp/#{idx}.jpg")
      result=`python qrscanner.py tmp/#{idx}.jpg`
      # puts idx.to_s + ' ' + result 
      if idx%10 == 0
        i=i+1
        err = 0
      end

      if result == ""
        err = err + 1
        if err > 5
          @result = false
          return
          # break
        end
      else
        begin
          num = result[-5..-1].to_i
          n.append(num)
        rescue
          @result = false
          return
        end
        if oldres == ""
          oldres=result
        else
          # puts idx.to_s + 'true'
          if idx<10 and idx>=0 and oldres!=result
            err = err + 1
            @result = false
          end
        end
      end
    end

          
    if  n.to_set.length != 16
      @result = false
    end

    # render :text => @result
  end

  def qrscanner

    File.open("tmp/qr.png",'wb') do |f|
      f.write params[:list][:file].read
    end
    @result=`python qrscanner.py tmp/qr.png`
    # render :text => result.to_s

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
      return
    end
    @a = []
    list = (start.to_i..ending.to_i).to_a
    puts list
    list.each do |i|
      str = 'KQ16' + '0'*(4-i.to_s.length) + i.to_s
      # qr = RQRCode::QRCode.new( str, :size => 4, :level => :h )
      qr_code_img = RQRCode::QRCode.new( str, :size => 2, :level => :l ).to_img

      check= Code.find_by_qr(str)

      if check and params[:list][:check] == "1"
        redirect_to :back, :alert => 'QR code for '+str+' exists'
        return
      end



      code = Code.new
      code.qr=str
      code.update_attribute :qrcode, qr_code_img.to_string
      code.save

      File.open("tmp/qr.png",'wb') do |f|
        f.write qr_code_img.to_string
      end

      f=File.open("tmp/qr.png",'r')

      j = Dragonfly.app.store(f)
      # j=images.fetch(qr_code_img)
      x={:code => str, :path => '/system/dragonfly/development/'+j}
      @a.append(x)

      @codes.append(code)
      # @qr.append(qr)
    end
     respond_to do |format|
      format.html { render layout: 'qr' }
      format.pdf do
        render :pdf => 'file_name',
        # show_as_html:   true,
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
