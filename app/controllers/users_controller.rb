class UsersController < ApplicationController
  def index
    authorize User

    if params.has_key? :q
      # respond with tokens if query paramater is provided
      # useful for client-side token-input (like jQuery token-input)
      @users = User.tokens(params[:q])
      render json: @users

    else
      @users = User.all
    end
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def secure_params
    params.require(:user).permit(:role)
  end

end
