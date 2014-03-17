class RegistrationsController < Devise::RegistrationsController
  rescue_from Paypal::Exception::APIError, with: :paypal_api_error

  def create
    @user = User.new user_params

    if @user.valid?
      session[:user] = params[:user]

      request = Paypal::Express::Request.new PAYPAL_CONFIG

      response = request.setup(
        payment_request(50),
        users_success_url,
        cancel_user_registration_url
      )
      redirect_to response.redirect_uri  
    else
      render 'new'
    end
    
  end


  def success

    # To checkout
    request   = Paypal::Express::Request.new PAYPAL_CONFIG
    response = request.checkout!(
      params[:token],
      params[:PayerID],
      payment_request(50)
    )

    params[:user] = session[:user]
    @user = User.new user_params
    
    if @user.save
      sign_up :user, @user
      redirect_to after_sign_up_path_for(@user)
    else
      render 'new'
    end
  end


  def cancel
    render 'new'
  end


  private

  def paypal_api_error(e)
    redirect_to root_url, error: e.response.details.collect(&:long_message).join('<br />')
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def payment_request(amount)
    Paypal::Payment::Request.new(
      :currency_code => :USD,     # if nil, PayPal use USD as default
      :description   => "You have to pay $#{amount} for sign up",    # item description
      :amount        => amount    # item value
    ) 
  end

end
