class Account::SaloonsController < Account::ApplicationController
  account_load_and_authorize_resource :saloon, through: :team, through_association: :saloons

  # GET /account/teams/:team_id/saloons
  # GET /account/teams/:team_id/saloons.json
  def index
    delegate_json_to_api
  end

  # GET /account/saloons/:id
  # GET /account/saloons/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/saloons/new
  def new
  end

  # GET /account/saloons/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/saloons
  # POST /account/teams/:team_id/saloons.json
  def create
    respond_to do |format|
      if @saloon.save
        format.html { redirect_to [:account, @saloon], notice: I18n.t("saloons.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @saloon] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @saloon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/saloons/:id
  # PATCH/PUT /account/saloons/:id.json
  def update
    respond_to do |format|
      if @saloon.update(saloon_params)
        format.html { redirect_to [:account, @saloon], notice: I18n.t("saloons.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @saloon] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @saloon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/saloons/:id
  # DELETE /account/saloons/:id.json
  def destroy
    @saloon.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :saloons], notice: I18n.t("saloons.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
