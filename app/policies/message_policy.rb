class MessagePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # scope lié à la route "messages#index" qui ne sera pas utilisée mais qui permet de se logger sans bug pour le moment
    def resolve
      scope.where(user: user)
    end
  end

  def new?
    true
  end

  def create?
    true
  end

  def awaiting_answer?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def dismiss_suggestion?
    true
  end

  def reply?
    true
  end

  def rekonect?
    true
  end

  def send_message?
  true
  end
end
