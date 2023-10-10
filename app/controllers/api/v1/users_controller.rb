class Api::V1::UsersController < Api::V1::AuthenticatedController
    before_action :set_user, only: %i[show update destroy]

    def index
        @users = User.all
        render json: @users

    end
    
    def show
        #render json: @user
        #render json: UserSerializer.new(@user).serializable_hash.to_json
        options = { include: [:products] }
        render json: UserSerializer.new(@user, options).serializable_hash.to_json
    end

    def create
        @user = User.new(user_params)

        if @user.save
            render json: @user, status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end

    end

    # PATCH/PUT /users/1
    def update
        if @user.update(user_params)
            render json: @user, status: :ok
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end


    # DELETE /users/1
    def destroy
        @user.destroy
        head 204
    end


    private

    def set_user
        @user = User.find(params[:id])
    end
    
    def user_params
        params.require(:user).permit(:name, :email, :password)
    end

end

