class Admin::UsersController < ApplicationController
  authorize_resource

  before_action :set_user, only: [:destroy, :lock, :unlock, :toggle_admin]

  def index
    @users = User.all
    @selected_options = {}
    
    sanitizer = Rails::Html::FullSanitizer.new
    (['locked', 'admin'] & params.keys).each do |key|
      @selected_options[key.to_sym] = params[key].is_a?(Array) ? params[key].map { |e| sanitizer.sanitize e } : sanitizer.sanitize(params[key])
    end
    if @selected_options[:locked]
      case @selected_options[:locked]
      when 'true'
        @users = @users.where(locked_at: { '$exists': true })
      when 'false'
        @users = @users.where(locked_at: { '$exists': false })
      end
    end
    if @selected_options[:admin]
      case @selected_options[:admin]
      when 'true'
        @users = @users.where(admin: true)
      when 'false'
        @users = @users.where(admin: false)
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def lock
    @user.lock_access!
    redirect_to admin_users_path, notice: 'User was successfully locked.'
  end

  def unlock
    @user.unlock_access!
    redirect_to admin_users_path, notice: 'User was successfully unlocked.'
  end

  def toggle_admin
    @user.toggle_admin!
    redirect_to admin_users_path, notice: "Admin status successfully #{@user.admin? ? 'set' : 'removed'}."
  end

  private

  def set_user
    @user = User.find(params[:id] || params[:user_id])
  end
end
