class ConversationsController < ApplicationController
  skip_after_action :verify_authorized, only: [:show]

  def show
    # if params[:contact_name].present?
    #   contact_name = params[:contact_name].tr('-', ' ')
    #   contact = Contact.find_by('LOWER(name) = ?', contact_name.downcase)
    #   if contact.nil?
    #     redirect_to root_path, alert: "Contact introuvable." and return
    #   end
    #   # Cherche la conversation existante entre current_user et ce contact
    #   @conversation = Conversation.find_by(
    #     contact_id: contact&.id,
    #     user1_id: current_user.id,
    #     user2_id: contact.contact_user_id
    #   ) || Conversation.find_by(
    #     contact_id: contact&.id,
    #     user1_id: contact.contact_user_id,
    #     user2_id: current_user.id
    #   )
    #   # Si elle n'existe pas, crée-la
    #   if @conversation.nil? && contact.present?
    #     @conversation = Conversation.create(contact_id: contact.id, user1_id: current_user.id, user2_id: contact.user_id)
    #   end
    # elsif params[:id].present?
    #   @conversation = Conversation.find_by(id: params[:id])
    # else
    #   redirect_to root_path, alert: "Conversation introuvable." and return
    # end

    @conversation = Conversation.find(params[:id])
    if @conversation.nil?
      redirect_to root_path, alert: "Conversation introuvable." and return
    end

    authorize @conversation
    @messages = @conversation.messages.order(:created_at)
    @conversations = policy_scope(Conversation)
  end

end
