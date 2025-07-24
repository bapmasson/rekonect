class ContactsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized, only: [:circles]

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

  def edit
    @contact = Contact.find(params[:id])
    authorize @contact
  end

  def update
    @contact = Contact.find(params[:id])
    authorize @contact
    if @contact.update(contact_params)
      redirect_to contact_path(@contact), notice: "Contact mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def circles
    @contacts = policy_scope(Contact)
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :notes, :relationship_id, :photo)
  end
end
