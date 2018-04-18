class ItemsController < ApplicationController
  authorize_resource

  before_action :set_item, only: [:edit, :update, :destroy, :image, :thumb, :lock, :unlock, :claim, :unclaim]

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(permitted_params)
    if @item.save
      redirect_to items_path, notice: 'Item was successfully created.'
    else
      render 'edit'
    end
  end

  def edit
  end

  def update
    if @item.update_attributes(permitted_params)
      redirect_to items_path, notice: 'Item was successfully updated.'
    else
      render 'edit'
    end
  end

  def index
    @items = {}
    @users = User.all.to_a
    @users = [current_user] + (@users - [current_user])
    @locations = (Item.distinct(:location) - ['']).sort

    sanitizer = Rails::Html::FullSanitizer.new
    @selected_options = {}
    (['locked', 'location', 'users', 'claimed'] & params.keys).each do |key|
      @selected_options[key.to_sym] = params[key].is_a?(Array) ? params[key].map { |e| sanitizer.sanitize e } : sanitizer.sanitize(params[key])
    end

    query = Item.all
    if @selected_options[:locked]
      case @selected_options[:locked]
      when 'true'
        query = query.where(locked: true)
      when 'false'
        query = query.where(locked: false)
      end
    end
    if @selected_options[:location].is_a?(Array) && @selected_options[:location].all? {|l| (@locations + ['']).include?(l)}
      query = query.in(location: @selected_options[:location])
    end
    if @selected_options[:claimed]
      case @selected_options[:claimed]
      when 'noone'
        query = query.where('$or' => [{user_ids: []}, {user_ids: {'$exists' => false}}])
      when 'one'
        query = query.where(user_ids: {'$size' => 1})
      when 'several'
        query = query.where('user_ids.1' => {'$exists' => true})
      end
    end
    if @selected_options[:users].is_a?(Array) && @selected_options[:users].all? {|u| !(@users.select{|c| c.username == u}.empty?)}
      query = query.in(user_ids: @users.select{|u| @selected_options[:users].include?(u.username)}.map{|u| u.id})
    end

    @selected_options[:location] ||= []
    @selected_options[:users] ||= []

    query.each do |i|
      @items[i.location] ||= []
      @items[i.location] << i
    end

  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: 'Item was successfully deleted.'
  end

  def lock
    if @item.lock!
      flash[:success] = 'Item was successfully locked.'
      redirect_back fallback_location: items_path
    else
      flash[:danger] = 'Unable to lock item'
      redirect_back fallback_location: items_path
    end
  end

  def unlock
    if @item.unlock!
      flash[:success] = 'Item was successfully unlocked.'
      redirect_back fallback_location: items_path
    else
      flash[:danger] = 'Unable to unlock item'
      redirect_back fallback_location: items_path
    end
  end

  def claim
    if @item.locked
      flash[:danger] = 'This item is locked, you can not claim it'
      redirect_back fallback_location: items_path
    end
    @item.users << current_user
    @item.users.uniq!
    if @item.save
      flash[:success] = 'You successfully claimed the item.'
      redirect_back fallback_location: items_path
    else
      flash[:danger] = 'Unable to claim the item'
      redirect_back fallback_location: items_path
    end
  end

  def unclaim
    if @item.locked
      flash[:danger] = 'This item is locked, you can not release it'
      redirect_back fallback_location: items_path
    end
    @item.users.delete(current_user)
    if @item.save
      flash[:success] = 'You successfully released the item.'
      redirect_back fallback_location: items_path
    else
      flash[:danger] = 'Unable to release the item'
      redirect_back fallback_location: items_path
    end
  end

  def image
    img = @item.image
    img = @item.image.thumb if params[:version] == 'thumb'
    img = @item.image.big if params[:version] == 'big'
    send_data img.read, type: img.file.content_type, disposition: 'inline', x_sendfile: true
  end

  private

  def set_item
    @item = Item.find(params[:item_id] || params[:id])
  end

  def permitted_params
    params.require(:item).permit(:ref, :description, :location, :image)
  end
end
