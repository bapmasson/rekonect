class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @contacts = policy_scope(current_user.contacts)
  end

  def new
    @contact = Contact.new
    authorize @contact
  end

  def create
    @contact = current_user.contacts.build(contact_params)
    authorize @contact
    if @contact.save
      redirect_to contacts_path, notice: "Contact ajouté avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @contact = Contact.find(params[:id])
    authorize @contact
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :notes, :relationship_id, :photo)
  end
end
