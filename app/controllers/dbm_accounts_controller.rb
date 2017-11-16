class DbmAccountsController < ApplicationController
  wrap_parameters :dbm_account, include: [:name, :password, :enabled]

  before_action :set_dbm_account, only: [:show, :edit, :update, :destroy]
  before_action :set_dbm, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /dbms/dbm_id/dbm_account
  # GET /dbms/dbm_id/dbm_account.json
  def index
    @dbm_account = current_user.dbm_accounts.where(dbm_id: params[:dbm_id])
  end

  # GET /dbms/dbm_id/dbm_account/new
  def new
    @dbm_account = DbmAccount.new
    @dbm_account.enabled = true
    @dbm_account.dbm = @dbm
  end

  # GET /dbms/dbm_id/dbm_account/1
  # GET /dbms/dbm_id/dbm_account/1.json
  def show
    respond_to do |format|
        format.html { redirect_to dbm_dbm_accounts_path(@dbm) }
        format.json { render :show }
    end
  end

  # GET /dbms/dbm_id/dbm_account/1/edit
  def edit
  end

  # POST /dbms/dbm_id/dbm_account
  # POST /dbms/dbm_id/dbm_account.json
  def create
    @dbm_account = DbmAccount.new(dbm_account_params)
    @dbm_account.user = current_user
    @dbm_account.dbm = @dbm

    respond_to do |format|
      if @dbm_account.save
        format.html { redirect_to dbm_dbm_account_path(@dbm), notice: 'Dbm Account was successfully created.' }
        format.json { render :show, status: :created, location: dbm_dbm_account_path(@dbm, @dbm_account) }
      else
        format.html { render :new }
        format.json { render json: @dbm_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dbms/dbm_id/dbm_account/1
  # PATCH/PUT /dbms/dbm_id/dbm_account/1.json
  def update
    ok = true

    begin
      ok = @dbm_account.update(dbm_account_params)
    rescue => e
      ok = false
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbm_dbm_accounts_path(@dbm), notice: 'Dbm account was successfully updated.' }
        format.json { render :show, status: :ok, location: dbm_dbm_account_path(@dbm, @dbm_account) }
      else
        format.html { render :edit }
        format.json { render json: @dbm_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dbms/dbm_id/dbm_account/1
  # DELETE /dbms/dbm_id/dbm_account/1.json
  def destroy
    ok = true
    begin
      @dbm_account.destroy
    rescue => e
      ok = false
    end

    respond_to do |format|
      if ok
        format.html { redirect_to dbm_abm_accounts_path(@dbm), notice: 'Dbm account was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to dbm_dbm_accounts_path(@dbm), error: 'Failed to delete Dbm account.' }
        format.json { head :no_content, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dbm_account
      @dbm_account = DbmAccount.find(params[:id])
    end

    def set_dbm
      @dbm = Dbm.find(params[:dbm_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dbm_account_params
      params.require(:dbm_account).permit(:name, :password, :enabled)
    end
end
