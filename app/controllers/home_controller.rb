class HomeController < ApplicationController
  def show
    if can? :read, Item
      item_time = current_user.last_sign_in_at || Time.at(0)
      @new_items = Item.where(created_at: {'$gte' => item_time}).sort(created_at: -1).to_a
      @recently_locked_items = Item.where(locked_at: {'$gte' => item_time})
      @claimed_items = Item.where(user_ids: current_user._id).sort(updated_at: -1).to_a
    end
    if can? :manage, User
      @new_users = []
      @locked_users = []
    end
  end
end
