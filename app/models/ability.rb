class Ability
  include CanCan::Ability

  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    unless user.nil?
      if user.admin?
        can :manage, :all
      else
        can :read, Item
        can :claim, Item
        can :unclaim, Item
        can :image, Item
      end
    end
  end
end
